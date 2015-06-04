execute 'ovs-vsctl add-br br-bare' do
  not_if 'ovs-vsctl show | grep br-bare'
end

execute 'ovs-vsctl add-port br-bare enp0s8' do
  not_if 'ovs-vsctl show | grep enp0s8'
  notifies :run, 'execute[restart openvswitch agent]', :immediately
end

execute 'restart openvswitch agent' do
  command 'systemctl restart neutron-openvswitch-agent.service'
  action :nothing
end
