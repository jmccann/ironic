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

execute 'create baremetal net' do
    environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
                'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  command 'neutron net-create baremetal --shared --provider:network_type flat --provider:physical_network physbare'
  not_if 'neutron net-list -F name | egrep "\|[ ]+baremetal[ ]+\|"'
end

execute 'create baremetal subnet' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  command 'neutron subnet-create baremetal 192.168.50.0/24 --name baremetal-subnet --ip-version=4 --gateway=192.168.50.1 --allocation-pool start=192.168.50.100,end=192.168.50.200 --enable-dhcp'
  not_if 'neutron subnet-list -F name | egrep "\|[ ]+baremetal-subnet[ ]+\|"'
end
