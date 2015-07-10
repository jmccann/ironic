remote_file "#{node['openstack']['bare-metal']['tftp']['root_path']}/discovery.kernel" do
  source node['ironic']['inspector']['discovery_kernel']
  action :create_if_missing
end

remote_file "#{node['openstack']['bare-metal']['tftp']['root_path']}/discovery.initramfs" do
  source node['ironic']['inspector']['discovery_initramfs']
  action :create_if_missing
end
