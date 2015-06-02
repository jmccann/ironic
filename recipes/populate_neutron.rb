execute 'create private net' do
  command 'source ~/openrc && neutron net-create private'
  not_if "source ~/openrc && neutron net-list -F name | grep '| private |'"
end

execute 'create private subnet' do
  command 'source ~/openrc && neutron subnet-create --name private-subnet private 10.1.0.0/24'
  not_if "source ~/openrc && neutron subnet-list -F name | egrep '\|[ ]+private-subnet[ ]+\|'"
end

execute 'create baremetal net' do
  command 'source ~/openrc && neutron net-create baremetal'
  not_if "source ~/openrc && neutron net-list -F name | grep '| baremetal |'"
end

execute 'create baremetal subnet' do
  command 'source ~/openrc && neutron subnet-create --name baremetal-subnet private 192.168.50.0/24'
  not_if "source ~/openrc && neutron subnet-list -F name | grep '| baremetal-subnet |'"
end
