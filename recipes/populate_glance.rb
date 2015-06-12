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

remote_file '/var/tmp/cirros-0.3.2-x86_64-disk.img' do
  source 'http://download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img'
  action :create_if_missing
end

remote_file '/var/tmp/coreos_production_pxe.vmlinuz' do
  source 'http://tarballs.openstack.org/ironic-python-agent/coreos/files/coreos_production_pxe.vmlinuz'
  action :create_if_missing
end

remote_file '/var/tmp/coreos_production_pxe_image-oem.cpio.gz' do
  source 'http://tarballs.openstack.org/ironic-python-agent/coreos/files/coreos_production_pxe_image-oem.cpio.gz'
  action :create_if_missing
end

execute 'glance image-create --name cirros --disk-format qcow2 --container-format bare < /var/tmp/cirros-0.3.2-x86_64-disk.img' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  not_if <<-EOF
    export OS_USERNAME=#{admin_user}
    export OS_PASSWORD=#{admin_pass}
    export OS_TENANT_NAME=#{admin_tenant}
    export OS_AUTH_URL=#{auth_uri}

    glance image-list | egrep "\|[ ]+cirros[ ]+\|"
  EOF
end

# Can't use openstack_image_image due to poor ami support and lack of direct aki/ari support
execute 'glance image-create --name ir-deploy-agent.kernel --disk-format aki --container-format aki < /var/tmp/coreos_production_pxe.vmlinuz' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  not_if <<-EOF
    export OS_USERNAME=#{admin_user}
    export OS_PASSWORD=#{admin_pass}
    export OS_TENANT_NAME=#{admin_tenant}
    export OS_AUTH_URL=#{auth_uri}

    glance image-list | egrep "\|[ ]+ir-deploy-agent.kernel[ ]+\|"
  EOF
end

execute 'glance image-create --name ir-deploy-agent.initramfs --disk-format ari --container-format ari < /var/tmp/coreos_production_pxe_image-oem.cpio.gz' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  not_if <<-EOF
    export OS_USERNAME=#{admin_user}
    export OS_PASSWORD=#{admin_pass}
    export OS_TENANT_NAME=#{admin_tenant}
    export OS_AUTH_URL=#{auth_uri}

    glance image-list | egrep "\|[ ]+ir-deploy-agent.initramfs[ ]+\|"
  EOF
end
