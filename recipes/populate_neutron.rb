include_recipe 'openstack-network::server'

# Need to restart immediately for CLI commands to work
execute 'restart neutron' do
  command 'systemctl restart neutron-server.service'
  action :nothing
  only_if 'pgrep neutron-server'
end

r = resources('template[/etc/neutron/plugins/ml2/ml2_conf.ini]')
r.notifies :run, 'execute[restart neutron]', :immediately

class ::Chef::Recipe # rubocop:disable all
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

service 'NetworkManager' do
  action [:disable, :stop]
end

execute 'refresh neutron net cache' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  command 'neutron net-list > /var/tmp/net.list'
end

execute 'refresh neutron subnet cache' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  command 'neutron subnet-list > /var/tmp/subnet.list'
end

node['ironic']['bridges'].each do |br, data|
  execute "Add bridge #{br}" do
    command "ovs-vsctl add-br #{br}"
    not_if "ovs-vsctl show | grep 'Bridge #{br}'"
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

  execute "sets #{br} link UP" do
    command "ip link set #{br} up"
    not_if "ip link show #{br} | grep UP"
  end

  execute "remove IP from #{data['interface']}" do
    command "ip addr del #{data['ip']}/#{data['mask']} dev #{data['interface']}"
    only_if { data.key?('ip') && data.key?('mask') }
    only_if "ip a show #{data['interface']} | grep ' #{data['ip']}/#{data['mask']}'"
  end

  execute "Sets IP config for #{br}" do
    command "ip addr add #{data['ip']}/#{data['mask']} dev #{br}"
    only_if { data.key?('ip') && data.key?('mask') }
    not_if "ip addr show #{br} | grep #{data['ip']}"
  end

  execute 'restart openvswitch agent' do
    command 'systemctl restart neutron-openvswitch-agent.service'
    action :nothing
  end
end

execute 'set default gateway' do
  command "route add default gw #{node['ironic']['gateway']}"
  not_if { node['ironic']['gateway'].nil? }
  not_if "route -n | awk '{print $1}' | grep '0.0.0.0'"
end

node['ironic']['neutron']['networks'].each do |net, data|
  execute "create #{net} net" do
    environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
                'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
    command "neutron net-create #{net} --shared --provider:network_type flat --provider:physical_network #{data['phys_net']}"
    not_if "egrep \"\\|[ ]+#{net}[ ]+\\|\" /var/tmp/net.list"
  end
end

node['ironic']['neutron']['subnets'].each do |subnet, data|
  execute "create #{subnet} subnet" do
    environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
                'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
    command "neutron subnet-create #{data['network_name']} #{data['network']}/#{data['mask']} --name #{subnet} --ip-version=4 --gateway=#{data['gateway']} --allocation-pool start=#{data['allocation_start']},end=#{data['allocation_end']} --enable-dhcp" # rubocop:disable LineLength
    not_if "egrep \"\\|[ ]+#{subnet}[ ]+\\|\" /var/tmp/subnet.list"
  end
end
