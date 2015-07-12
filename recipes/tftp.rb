package 'syslinux-tftpboot'

include_recipe 'tftp::server'

# Override template to be able to specify flags
r = resources('template[/etc/xinetd.d/tftp]')
r.cookbook 'ironic'

# Override tftpboot directory owner so ironic can write to it
r = resources("directory[#{node['tftp']['directory']}]")
r.owner 'ironic'
r.group 'ironic'

directory "#{node['openstack']['bare-metal']['tftp']['root_path']}/pxelinux.cfg" do
  user 'ironic'
  group 'ironic'
  mode 0755
  recursive true
end

directory "#{node['openstack']['bare-metal']['tftp']['root_path']}/var/lib" do
  user 'ironic'
  group 'ironic'
  recursive true
end

execute 'ln -s ../.. tftpboot' do
  cwd "#{node['openstack']['bare-metal']['tftp']['root_path']}/var/lib"
  not_if "[ -e #{node['openstack']['bare-metal']['tftp']['root_path']}/var/lib/tftpboot ]"
end
