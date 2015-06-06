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

execute 'ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa' do
  creates '/root/.ssh/id_rsa'
end

execute 'nova keypair-add default --pub-key ~/.ssh/id_rsa.pub' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  not_if 'nova keypair-list | grep default'

  # Start ironic before next resource ... why don't they start right away? :(
  notifies :start, 'service[ironic-conductor]', :immediately
  notifies :start, 'service[ironic-api]', :immediately
end

execute "ironic node-create -n my-baremetal -d agent_vbox -i virtualbox_host='10.0.2.2' -i virtualbox_vmname='baremetal'" do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  retries 10
  retry_delay 10
  not_if 'ironic node-show my-baremetal'
end

execute 'add node metadata' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  command <<-EOF
    NODE_UUID=$(ironic node-list | egrep "my-baremetal"'[^-]' | awk '{ print $2 }')
    IMG_SRC=$(glance image-list | egrep -- 'cirros ' | awk '{print $2}') # For agent_vbox
    IMG_KERN=$(glance image-list | egrep 'ir-deploy-agent.kernel ' | awk '{print $2}')
    IMG_RAM=$(glance image-list | egrep 'ir-deploy-agent.initramfs ' | awk '{print $2}')

    MAC_ADDRESS=08:00:27:6E:DF:70
    RAM_MB=4096
    CPU=1
    DISK_GB=11
    ARCH=x86_64

    ironic node-update my-baremetal add \
    properties/cpus=$CPU \
    properties/memory_mb=$RAM_MB \
    properties/local_gb=$DISK_GB \
    properties/cpu_arch=$ARCH

    ironic node-update my-baremetal add instance_info/root_gb=$DISK_GB
    ironic node-update my-baremetal add instance_info/image_source=$IMG_SRC
    ironic node-update my-baremetal add driver_info/deploy_kernel=$IMG_KERN
    ironic node-update my-baremetal add driver_info/deploy_ramdisk=$IMG_RAM

    ironic port-create -n $NODE_UUID -a $MAC_ADDRESS
  EOF
  not_if "ironic port-list | grep '08:00:27:6e:df:70'"
end

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
