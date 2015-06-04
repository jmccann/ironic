include_recipe 'tftp::server'

# directory "#{node['tftp']['directory']}/pxelinux.cfg" do
#   mode '0755'
# end

package 'syslinux-tftpboot'

execute 'chmod -R 777 /var/lib/tftpboot'
