node['ironic']['interfaces'].each do |int, br|
  execute "ovs-vsctl add-br #{br['name']}" do
    not_if "ovs-vsctl show | grep #{br}"
  end

  execute "ovs-vsctl add-port #{br['name']} #{int}" do
    not_if "ovs-vsctl show | grep #{int}"
    notifies :run, 'execute[restart openvswitch agent]', :immediately
  end

  execute "ip link set #{int} up" do
    not_if "ip link show #{int} | grep UP"
  end

  execute "ifconfig #{br['name']} #{br['ip']} netmask #{br['netmask']} up" do
    not_if "ip addr show #{br['name']} | grep #{br['ip']}"
  end

  execute 'restart openvswitch agent' do
    command 'systemctl restart neutron-openvswitch-agent.service'
    action :nothing
  end
end
