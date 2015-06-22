class ::Chef::Recipe # rubocop:disable Documentation
  include ::Openstack
end

include_recipe 'ironic::tftp'
package 'git'
package 'qemu'
package 'dib-utils'

package 'openstack-ironic-discoverd' do
  options '--nogpgcheck'
end

directory "#{node['ironic']['inspector']['tftpboot_path']}/pxelinux.cfg" do
  mode 0755
  recursive true
end
remote_file "#{node['ironic']['inspector']['tftpboot_path']}/pxelinux.0" do
  mode 0644
  source 'file:////var/lib/tftpboot/pxelinux.0'
end
template "#{node['ironic']['inspector']['tftpboot_path']}/pxelinux.cfg/default" do
  mode 0644
end

git '/var/tmp/diskimage-builder' do
  repository 'https://github.com/openstack/diskimage-builder.git'
  reference 'master'
  action :sync
end

# 'Fix' disocoverd to detect memory when no in dmidecode
cookbook_file '/var/tmp/diskimage-builder/elements/ironic-discoverd-ramdisk/init.d/80-ironic-discoverd-ramdisk'

execute 'create discovery ramdisk' do
  cwd '/var/tmp'
  command 'ramdisk-image-create -o discovery fedora ironic-discoverd-ramdisk'
  environment 'PATH' => '/var/tmp/diskimage-builder/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
              'DIB_DISTRIBUTION_MIRROR' => 'http://download.fedoraproject.org/pub/fedora/linux'
  creates '/var/tmp/discovery.kernel'
  retries 6 # Keep retrying because yum mirrors can timeout
end

execute 'copy discovery kernel' do
  command "cp /var/tmp/discovery.kernel #{node['ironic']['inspector']['tftpboot_path']}/discovery.kernel"
  creates "#{node['ironic']['inspector']['tftpboot_path']}/discovery.kernel"
end

execute 'copy discovery initramfs' do
  command "cp /var/tmp/discovery.initramfs #{node['ironic']['inspector']['tftpboot_path']}/discovery.initramfs"
  creates "#{node['ironic']['inspector']['tftpboot_path']}/discovery.initramfs"
end

identity_endpoint = internal_endpoint 'identity-internal'
identity_admin_endpoint = admin_endpoint 'identity-admin'
service_pass = get_password 'service', 'openstack-bare-metal'

auth_uri = auth_uri_transform(identity_endpoint.to_s, node['openstack']['bare-metal']['api']['auth']['version'])
identity_uri = identity_uri_transform(identity_admin_endpoint)

template '/etc/ironic-discoverd/discoverd.conf' do
  owner 'ironic'
  group 'ironic'
  mode 0640
  variables auth_uri: auth_uri,
            identity_uri: identity_uri,
            service_pass: service_pass
  notifies :restart, 'service[openstack-ironic-discoverd]', :delayed
end

template '/etc/ironic-discoverd/dnsmasq.conf' do
  owner 'ironic'
  group 'ironic'
  mode 0640
  notifies :restart, 'service[openstack-ironic-discoverd-dnsmasq]', :delayed
end

service 'openstack-ironic-discoverd' do
  action [:start, :enable]
end

service 'openstack-ironic-discoverd-dnsmasq' do
  action [:start, :enable]
end

# Enable inspect for agent_vbox
cookbook_file '/usr/lib/python2.7/site-packages/ironic/drivers/agent.py' do
  notifies :restart, 'service[ironic-conductor]', :delayed
end
