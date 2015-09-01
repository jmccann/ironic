include_recipe 'fake::helper_scripts'

include_recipe 'openstack-common::default'

package 'openvswitch'

service 'openvswitch' do
  action [:enable, :start]
end

execute '/root/scripts/setup-network' do
  not_if 'virsh net-list | grep brbm'
end

execute 'ip addr add 192.168.50.1/24 dev brbm' do
  not_if 'ip a show brbm | grep 192.168.50.1'
end

execute 'ip link set brbm up' do
  not_if 'ip a show brbm | grep UP'
end
