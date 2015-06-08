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

# Override proxy-server template to:
#   Allow delay_auth_decision for authtoken
#   Adding tempurl to pipeline without swauth
r = resources('template[/etc/swift/proxy-server.conf]')
r.cookbook 'ironic'

execute 'Set swift tempurl key' do
  command "swift post -m temp-url-key:#{admin_pass}"
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  not_if 'swift stat | grep "Meta Temp-Url-Key"'
  sensitive true
end
