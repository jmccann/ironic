class ::Chef::Recipe # rubocop:disable all
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

execute 'ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa' do
  creates '/root/.ssh/id_rsa'
end

remote_file '/root/.ssh/authorized_keys' do
  source 'file:///root/.ssh/id_rsa.pub'
end

remote_file '/tmp/ssh_key' do
  owner 'ironic'
  mode '0600'
  source 'file:///root/.ssh/id_rsa'
end

execute 'nova keypair-add default --pub-key ~/.ssh/id_rsa.pub' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  not_if 'nova keypair-list | grep default'

  # Start ironic before next resource ... why don't they start right away? :(
  notifies :start, 'service[ironic-conductor]', :immediately
  notifies :start, 'service[ironic-api]', :immediately
end

include_recipe 'fake::create_nodes'

execute 'add flavor' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  command <<-EOF
    RAM_MB=4096
    CPU=1
    DISK_GB=11
    ARCH=x86_64

    nova flavor-create my-baremetal-flavor auto $RAM_MB $DISK_GB $CPU
    nova flavor-key my-baremetal-flavor set cpu_arch=$ARCH
  EOF
  not_if 'nova flavor-show my-baremetal-flavor'
end
