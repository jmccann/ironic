package 'qemu'
package 'dib-utils'
package 'git'

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
  command "cp /var/tmp/discovery.kernel #{node['openstack']['bare-metal']['tftp']['root_path']}/discovery.kernel"
  creates "#{node['openstack']['bare-metal']['tftp']['root_path']}/discovery.kernel"
end

execute 'copy discovery initramfs' do
  command "cp /var/tmp/discovery.initramfs #{node['openstack']['bare-metal']['tftp']['root_path']}/discovery.initramfs"
  creates "#{node['openstack']['bare-metal']['tftp']['root_path']}/discovery.initramfs"
end
