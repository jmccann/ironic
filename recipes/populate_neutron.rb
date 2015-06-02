execute 'create private net' do
  command 'source ~/openrc && neutron net-create private'
  not_if 'source ~/openrc && neutron net-list -F name | egrep "\|[ ]+private[ ]+\|"'
end

execute 'create private subnet' do
  command 'source ~/openrc && neutron subnet-create --name private-subnet private 10.1.0.0/24'
  not_if 'source ~/openrc && neutron subnet-list -F name | egrep "\|[ ]+private-subnet[ ]+\|"'
end

execute 'create baremetal net' do
  command 'source ~/openrc && neutron net-create baremetal --provider:network_type flat --provider:physical_network physbaremetal'
  not_if 'source ~/openrc && neutron net-list -F name | egrep "\|[ ]+baremetal[ ]+\|"'
end

execute 'create baremetal subnet' do
  command 'source ~/openrc && neutron subnet-create baremetal 192.168.50.0/24 --name baremetal-subnet --ip-version=4 --gateway=192.168.50.1 --allocation-pool start=192.168.50.100,end=192.168.50.200 --enable-dhcp'
  not_if 'source ~/openrc && neutron subnet-list -F name | egrep "\|[ ]+baremetal-subnet[ ]+\|"'
end
