include_recipe 'openstack-object-storage::common'
include_recipe 'openstack-object-storage::storage-common'

class Chef::Recipe # rubocop:disable Documentation
  include ServiceUtils
end

platform_options = node['openstack']['object-storage']['platform']

platform_options['account_packages'].each.each do |pkg|
  package pkg do
    action :upgrade
    options platform_options['override_options'] # retain configs
  end
end

svc_names = {}
%w{swift-account swift-account-auditor swift-account-reaper swift-account-replicator}.each do |svc|
  svc_names[svc] = svc_name(svc)
end

svc_names.values.each do |svc|
  service svc do
    supports status: true, restart: true
    action [:enable, :start]
    only_if '[ -e /etc/swift/account-server.conf ] && [ -e /etc/swift/account.ring.gz ]'
  end
end

# create account server template
template '/etc/swift/account-server.conf' do
  source 'account-server.conf.erb'
  owner node['openstack']['object-storage']['user']
  group node['openstack']['object-storage']['group']
  mode 00600
  variables(
    'bind_ip' => node['openstack']['object-storage']['network']['account-bind-ip'],
    'bind_port' => node['openstack']['object-storage']['network']['account-bind-port']
  )

  notifies :restart, "service[#{svc_names['swift-account']}]", :immediately
  notifies :restart, "service[#{svc_names['swift-account-auditor']}]", :immediately
  notifies :restart, "service[#{svc_names['swift-account-reaper']}]", :immediately
  notifies :restart, "service[#{svc_names['swift-account-replicator']}]", :immediately
  cookbook 'openstack-object-storage'
end
