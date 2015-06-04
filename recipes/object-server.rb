# Copy of original object-server minus openstack-object-storage::disks recipe

include_recipe 'openstack-object-storage::common'
include_recipe 'openstack-object-storage::storage-common'

class Chef::Recipe # rubocop:disable Documentation
  include ServiceUtils
end

platform_options = node['openstack']['object-storage']['platform']

platform_options['object_packages'].each do |pkg|
  package pkg do
    action :upgrade
    options platform_options['override_options']
  end
end

svc_names = {}
%w{swift-object swift-object-replicator swift-object-auditor swift-object-updater}.each do |svc|
  svc_names[svc] = svc_name(svc)
end

svc_names.values.each do |svc|
  service svc do
    supports status: false, restart: true
    action [:enable, :start]
    only_if '[ -e /etc/swift/object-server.conf ] && [ -e /etc/swift/object.ring.gz ]'
  end

end

memcache_servers = memcached_servers.join ','

template '/etc/swift/object-expirer.conf' do
  source 'object-expirer.conf.erb'
  owner node['openstack']['object-storage']['user']
  group node['openstack']['object-storage']['group']
  mode 00600
  variables(
    'memcache_servers' => memcache_servers
  )
  cookbook 'openstack-object-storage'
end

template '/etc/swift/object-server.conf' do
  source 'object-server.conf.erb'
  owner node['openstack']['object-storage']['user']
  group node['openstack']['object-storage']['group']
  mode 00600
  variables(
    'bind_ip' => node['openstack']['object-storage']['network']['object-bind-ip'],
    'bind_port' => node['openstack']['object-storage']['network']['object-bind-port']
  )

  notifies :restart, "service[#{svc_names['swift-object']}]", :immediately
  notifies :restart, "service[#{svc_names['swift-object-replicator']}]", :immediately
  notifies :restart, "service[#{svc_names['swift-object-updater']}]", :immediately
  notifies :restart, "service[#{svc_names['swift-object-auditor']}]", :immediately
  cookbook 'openstack-object-storage'
end

cron 'swift-recon' do
  minute '*/5'
  command 'swift-recon-cron /etc/swift/object-server.conf'
  user node['openstack']['object-storage']['user']
end
