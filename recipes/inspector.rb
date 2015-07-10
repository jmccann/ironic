class Chef
  class Recipe # rubocop:disable Documentation
    include ::Openstack
  end
end

include_recipe 'openstack-bare-metal::conductor'
include_recipe 'ironic::tftp'

package 'openstack-ironic-discoverd' do
  options '--nogpgcheck'
end

directory "#{node['openstack']['bare-metal']['tftp']['root_path']}/pxelinux.cfg" do
  mode 0755
  recursive true
end
template "#{node['openstack']['bare-metal']['tftp']['root_path']}/pxelinux.cfg/default" do
  mode 0644
end

include_recipe 'ironic::build_inspector_discovery' if node['ironic']['inspector']['discovery_kernel'].nil? || node['ironic']['inspector']['discovery_initramfs'].nil?
include_recipe 'ironic::download_inspector_discovery' unless node['ironic']['inspector']['discovery_kernel'].nil? && node['ironic']['inspector']['discovery_initramfs'].nil?

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

ENV['OS_USERNAME'] = node['openstack']['bare-metal']['service_user']
ENV['OS_PASSWORD'] = service_pass
ENV['OS_TENANT_NAME'] = 'service'
ENV['OS_AUTH_URL'] = auth_uri

macs = Mixlib::ShellOut.new("ironic port-list | tail -n+3 | grep -v \+ | awk '{print $4}'")
macs.run_command

template '/etc/ironic-discoverd/dnsmasq.conf' do
  owner 'ironic'
  group 'ironic'
  mode 0640
  variables macs: macs.stdout
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
