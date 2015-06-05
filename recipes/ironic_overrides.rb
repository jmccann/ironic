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
    ENV['OS_USERNAME'] = node['openstack']['identity']['admin_user']
    ENV['OS_PASSWORD'] = 'password'
    ENV['OS_TENANT_NAME'] = node['openstack']['identity']['admin_tenant_name']
    ENV['OS_AUTH_URL'] = auth_uri

    node.default['openstack']['bare-metal']['swift']['account'] = `swift stat | grep Account: | awk '{print $2}'`

    # # Dynamically set the file resource's attribute
    # # Obtain the desired resource from resource_collection
    # file_r = run_context.resource_collection.find(:file => "/tmp/some_file")
    # # Update the content attribute
    # file_r.content node[:test][:content]
  end
end
