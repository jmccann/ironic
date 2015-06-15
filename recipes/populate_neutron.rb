# execute 'create private net' do
#   command 'source ~/openrc && neutron net-create private'
#   not_if 'source ~/openrc && neutron net-list -F name | egrep "\|[ ]+private[ ]+\|"'
# end
#
# execute 'create private subnet' do
#   command 'source ~/openrc && neutron subnet-create --name private-subnet private 10.1.0.0/24'
#   not_if 'source ~/openrc && neutron subnet-list -F name | egrep "\|[ ]+private-subnet[ ]+\|"'
# end

class ::Chef::Recipe # rubocop:disable Documentation
  include ::Openstack
end

identity_endpoint = internal_endpoint 'identity-internal'

# For glance client, only identity v2 is supported. See discussion on
# https://bugs.launchpad.net/openstack-chef/+bug/1207504
# So here auth_uri can not be transformed.
auth_uri = identity_endpoint.to_s

admin_user = node['openstack']['identity']['admin_user']
admin_pass = get_password 'user', admin_user
admin_tenant = node['openstack']['identity']['admin_tenant_name']

node['ironic']['bridges'].each do |br, data|
  execute "remove IP from #{data['interface']}" do
    command "ip addr del $(ip a show #{data['interface']} | grep ' #{data['ip']}/' | awk '{print $2}') dev #{data['interface']}"
    only_if { data.key?('ip') && data.key?('mask') }
    only_if "ip a show #{data['interface']} | grep ' #{data['ip']}/'"
  end

  execute "Add bridge #{br}" do
    command "ovs-vsctl add-br #{br}"
    not_if "ovs-vsctl show | grep #{br}"
  end

  execute "Adds interface #{data['interface']} as port to #{br}" do
    command "ovs-vsctl add-port #{br} #{data['interface']}"
    not_if "ovs-vsctl show | grep #{data['interface']}"
    notifies :run, 'execute[restart openvswitch agent]', :immediately
  end

  execute "Sets #{data['interface']} link UP" do
    command "ip link set #{data['interface']} up"
    not_if "ip link show #{data['interface']} | grep UP"
  end

  execute "Sets IP config for #{br}" do
    command "ifconfig #{br} #{data['ip']}/#{data['mask']} up"
    only_if { data.key?('ip') && data.key?('mask') }
    not_if "ip addr show #{br} | grep #{data['ip']}"
  end

  execute 'restart openvswitch agent' do
    command 'systemctl restart neutron-openvswitch-agent.service'
    action :nothing
  end
end

node['ironic']['networks'].each do |net, data|
  execute "create #{net} net" do
    environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
                'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
    command "neutron net-create #{net} --shared --provider:network_type flat --provider:physical_network #{data['phys_net']}"
    not_if <<-EOF
      export OS_USERNAME=#{admin_user}
      export OS_PASSWORD=#{admin_pass}
      export OS_TENANT_NAME=#{admin_tenant}
      export OS_AUTH_URL=#{auth_uri}

      neutron net-list -F name | egrep \"\\|[ ]+#{net}[ ]+\\|\"
    EOF
  end

  execute "create #{net} subnet" do
    environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
                'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
    command "neutron subnet-create #{net} #{data['network']}/#{data['mask']} --name #{net}-subnet --ip-version=4 --gateway=#{data['ip']} --allocation-pool start=#{data['allocation_start']},end=#{data['allocation_end']} --enable-dhcp" # rubocop:disable LineLength
    not_if <<-EOF
      export OS_USERNAME=#{admin_user}
      export OS_PASSWORD=#{admin_pass}
      export OS_TENANT_NAME=#{admin_tenant}
      export OS_AUTH_URL=#{auth_uri}

      neutron subnet-list -F name | egrep \"\\|[ ]+#{net}-subnet[ ]+\\|\"
    EOF
  end
end
