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

ruby_block 'Get swift auth' do
  block do
    ENV['OS_USERNAME'] = admin_user
    ENV['OS_PASSWORD'] = admin_pass
    ENV['OS_TENANT_NAME'] = admin_tenant
    ENV['OS_AUTH_URL'] = auth_uri

    node.default['openstack']['bare-metal']['swift']['account'] = `swift stat | grep Account: | awk '{print $2}'`
  end
end

ruby_block 'Get cleaning network id' do
  block do
    ENV['OS_USERNAME'] = admin_user
    ENV['OS_PASSWORD'] = admin_pass
    ENV['OS_TENANT_NAME'] = admin_tenant
    ENV['OS_AUTH_URL'] = auth_uri

    node.default['openstack']['bare-metal']['neutron']['cleaning_network_uuid'] = `neutron net-list | grep baremetal | awk '{print $2}'`
  end
end

package 'ipmitool'

# Resource required for execute[ironic db sync] (didn't use to be required)
directory '/var/log/ironic'

%w(ironic-conductor.log ironic-api.log).each do |f|
  file "/var/log/ironic/#{f}" do
    owner 'ironic'
  end
end
