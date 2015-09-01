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

include_recipe 'fake::helper_scripts'

execute 'create node1' do
  command '/root/scripts/create-node node1 1 4 10 amd64 brbm /usr/bin/qemu-system-x86_64 /var/log/ironic_vm_nodes > /var/tmp/node1.mac'
  not_if 'virsh list --all | grep node1'
end

execute 'enroll node1' do
  environment 'OS_USERNAME' => admin_user, 'OS_PASSWORD' => admin_pass,
              'OS_TENANT_NAME' => admin_tenant, 'OS_AUTH_URL' => auth_uri
  command <<-EOF
    ironic node-create --driver agent_ssh --name node-1 \
            -p cpus=1 \
            -p memory_mb=4096 \
            -p local_gb=10 \
            -p cpu_arch=x86_64 \
            -i deploy_kernel=$(glance image-show ir-deploy-agent.kernel | grep ' id ' | awk '{print $4}') \
            -i deploy_ramdisk=$(glance image-show ir-deploy-agent.initramfs | grep ' id ' | awk '{print $4}') \
            -i ssh_virt_type=virsh \
            -i ssh_address=10.0.2.15 \
            -i ssh_port=22 \
            -i ssh_username=root \
            -i ssh_key_filename=/tmp/ssh_key \
            | grep " uuid " | awk '{print $4}' > /var/tmp/node1.uuid
  EOF
  not_if 'ironic node-show node-1'
end

execute 'create node1 port' do
  command 'ironic port-create --address $(cat /var/tmp/node1.mac) --node $(cat /var/tmp/node1.uuid)'
  not_if 'ironic port-list | grep -i $(cat /var/tmp/node1.mac)'
  notifies :run, 'execute[add node1 mac to dnsmasq]', :immediately
end

execute 'add node1 mac to dnsmasq' do
  command 'echo "dhcp-host=$(cat /var/tmp/node1.mac),ignore" >> /etc/ironic-discoverd/discoverd.conf'
  action :nothing
end
