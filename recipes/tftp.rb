package 'syslinux-tftpboot'

include_recipe 'tftp::server'

# Override template to be able to specify flags
r = resources('template[/etc/xinetd.d/tftp]')
r.cookbook 'ironic'

# Override tftpboot directory owner so ironic can write to it
r = resources("directory[#{node['tftp']['directory']}]")
r.owner 'ironic'
r.group 'ironic'

directory '/var/lib/tftpboot/var/lib' do
  user 'ironic'
  group 'ironic'
  recursive true
end

execute 'ln -s ../.. tftpboot' do
  cwd '/var/lib/tftpboot/var/lib'
  not_if '[ -e /var/lib/tftpboot/var/lib/tftpboot ]'
end
