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

node['ironic']['interfaces'].each do |int, br|
  execute "ovs-vsctl add-br #{br['name']}" do
    not_if "ovs-vsctl show | grep #{br['name']}"
  end

  execute "ovs-vsctl add-port #{br['name']} #{int}" do
    not_if "ovs-vsctl show | grep #{int}"
    notifies :run, 'execute[restart openvswitch agent]', :immediately
  end

  execute "ip link set #{int} up" do
    not_if "ip link show #{int} | grep UP"
  end

  execute "ifconfig #{br['name']} #{br['ip']}/#{br['mask']} up" do
    not_if "ip addr show #{br['name']} | grep #{br['ip']}"
  end

  execute 'restart openvswitch agent' do
    command 'systemctl restart neutron-openvswitch-agent.service'
    action :nothing
  end

  execute "create #{br['net_name']} net" do
    environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
                'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
    command "neutron net-create #{br['net_name']} --shared --provider:network_type flat --provider:physical_network #{br['map_name']}"
    not_if "neutron net-list -F name | egrep \"\\|[ ]+#{br['net_name']}[ ]+\\|\""
  end

  execute "create #{br['net_name']} subnet" do
    environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
                'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
    command "neutron subnet-create #{br['net_name']} #{br['network']}/#{br['mask']} --name #{br['net_name']}-subnet --ip-version=4 --gateway=#{br['ip']} --allocation-pool start=#{br['allocation_start']},end=#{br['allocation_end']} --enable-dhcp" # rubocop:disable LineLength
    not_if "neutron subnet-list -F name | egrep \"\\|[ ]+#{br['net_name']}-subnet[ ]+\\|\""
  end
end
