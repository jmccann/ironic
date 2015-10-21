remote_file "#{node['openstack']['bare-metal']['tftp']['root_path']}/discovery.kernel" do
  source node['ironic']['inspector']['discovery_kernel']
  checksum node['ironic']['inspector']['discovery_kernel_checksum'] unless node['ironic']['inspector']['discovery_kernel_checksum'].nil?
  action :create_if_missing if node['ironic']['inspector']['discovery_kernel_checksum'].nil?
end

remote_file "#{node['openstack']['bare-metal']['tftp']['root_path']}/discovery.initramfs" do
  source node['ironic']['inspector']['discovery_initramfs']
  checksum node['ironic']['inspector']['discovery_initramfs_checksum'] unless node['ironic']['inspector']['discovery_initramfs_checksum'].nil?
  action :create_if_missing if node['ironic']['inspector']['discovery_kernel_checksum'].nil?
end
