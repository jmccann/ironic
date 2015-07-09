remote_file "#{node['ironic']['inspector']['tftpboot_path']}/discovery.kernel" do
  source node['ironic']['inspector']['discovery_kernel']
  action :create_if_missing
end

remote_file "#{node['ironic']['inspector']['tftpboot_path']}/discovery.initramfs" do
  source node['ironic']['inspector']['discovery_initramfs']
  action :create_if_missing
end
