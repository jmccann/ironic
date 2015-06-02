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

# Can't use openstack_image_image due to poor ami support and lack of direct aki/ari support
execute 'glance image-create --name ir-deploy-agent.kernel --disk-format aki --container-format aki --location http://tarballs.openstack.org/ironic-python-agent/coreos/files/coreos_production_pxe.vmlinuz' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  not_if 'glance image-list | egrep "\|[ ]+ir-deploy-agent.kernel[ ]+\|"'
end

execute 'glance image-create --name ir-deploy-agent.initramfs --disk-format ari --container-format ari --location http://tarballs.openstack.org/ironic-python-agent/coreos/files/coreos_production_pxe_image-oem.cpio.gz' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  not_if 'glance image-list | egrep "\|[ ]+ir-deploy-agent.initramfs[ ]+\|"'
end
