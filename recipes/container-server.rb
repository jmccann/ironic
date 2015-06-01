include_recipe 'openstack-object-storage::common'
include_recipe 'openstack-object-storage::storage-common'

class Chef::Recipe # rubocop:disable Documentation
  include ServiceUtils
end

platform_options = node['openstack']['object-storage']['platform']

platform_options['container_packages'].each do |pkg|
  package pkg do
    action :upgrade
    options platform_options['override_options']
  end
end

svc_names = {}
%w{swift-container swift-container-auditor swift-container-replicator swift-container-updater}.each do |svc|
  svc_names[svc] = svc_name(svc)
end

svc_names.values.each do |svc|
  service svc do
    supports status: true, restart: true
    action [:enable, :start]
    only_if '[ -e /etc/swift/container-server.conf ] && [ -e /etc/swift/container.ring.gz ]'
  end
end

memcache_servers = memcached_servers.join ','

template '/etc/swift/container-reconciler.conf' do
  source 'container-reconciler.conf.erb'
  owner node['openstack']['object-storage']['user']
  group node['openstack']['object-storage']['group']
  mode 00600
  variables(
    'memcache_servers' => memcache_servers
  )
  cookbook 'openstack-object-storage'
end

template '/etc/swift/container-server.conf' do
  source 'container-server.conf.erb'
  owner node['openstack']['object-storage']['user']
  group node['openstack']['object-storage']['group']
  mode 00600
  variables(
    'bind_ip' => node['openstack']['object-storage']['network']['container-bind-ip'],
    'bind_port' => node['openstack']['object-storage']['network']['container-bind-port']
  )

  notifies :restart, "service[#{svc_names['swift-container']}]", :immediately
  notifies :restart, "service[#{svc_names['swift-container-replicator']}]", :immediately
  notifies :restart, "service[#{svc_names['swift-container-updater']}]", :immediately
  notifies :restart, "service[#{svc_names['swift-container-auditor']}]", :immediately
  cookbook 'openstack-object-storage'
end

unless node['openstack']['object-storage']['container-server']['allowed_sync_hosts'] == []
  service_name = svc_name('swift-container-sync')
  template '/etc/swift/container-sync-realms.conf' do
    source 'container-sync-realms.conf.erb'
    owner node['openstack']['object-storage']['user']
    group node['openstack']['object-storage']['group']
    mode 00600

    notifies :restart, "service[#{service_name}]", :immediately
    cookbook 'openstack-object-storage'
  end

  service service_name do
    supports status: false, restart: true
    action [:enable, :start]
    only_if '[ -e /etc/swift/container-server.conf ] && [ -e /etc/swift/container.ring.gz ]'
  end
end
