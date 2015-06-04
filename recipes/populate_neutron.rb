# execute 'create private net' do
#   command 'source ~/openrc && neutron net-create private'
#   not_if 'source ~/openrc && neutron net-list -F name | egrep "\|[ ]+private[ ]+\|"'
# end
#
# execute 'create private subnet' do
#   command 'source ~/openrc && neutron subnet-create --name private-subnet private 10.1.0.0/24'
#   not_if 'source ~/openrc && neutron subnet-list -F name | egrep "\|[ ]+private-subnet[ ]+\|"'
# end

execute 'ip link set enp0s8 up' do
  not_if 'ip link show enp0s8 | grep UP'
end

execute 'ifconfig br-bare 192.168.50.1 netmask 255.255.255.0 up' do
  not_if 'ip addr show br-bare | grep 192.168.50.1'
end

execute 'create baremetal net' do
  command 'source ~/openrc && neutron net-create baremetal --shared --provider:network_type flat --provider:physical_network physbare'
  not_if 'source ~/openrc && neutron net-list -F name | egrep "\|[ ]+baremetal[ ]+\|"'
end

execute 'create baremetal subnet' do
  command 'source ~/openrc && neutron subnet-create baremetal 192.168.50.0/24 --name baremetal-subnet --ip-version=4 --gateway=192.168.50.1 --allocation-pool start=192.168.50.100,end=192.168.50.200 --enable-dhcp'
  not_if 'source ~/openrc && neutron subnet-list -F name | egrep "\|[ ]+baremetal-subnet[ ]+\|"'
end
