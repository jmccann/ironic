require 'spec_helper'

describe 'ironic::populate_neutron' do
  include ChefVault::TestFixtures.rspec_shared_context

  cached(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5', step_into: ['rhel_network_interface']) do |node, _server|
      node.set['ironic']['bridges']['br-bare']['interface'] = 'enp0s8'
      node.set['ironic']['bridges']['br-bare']['phys_net'] = 'physbare'
      node.set['ironic']['bridges']['br-bare']['ip'] = '192.168.50.1'
      node.set['ironic']['bridges']['br-bare']['mask'] = '24'

      node.set['ironic']['networks']['baremetal']['phys_net'] = 'physbare'
      node.set['ironic']['networks']['baremetal']['network'] = '192.168.50.0'
      node.set['ironic']['networks']['baremetal']['mask'] = '24'
      node.set['ironic']['networks']['baremetal']['allocation_start'] = '192.168.50.100'
      node.set['ironic']['networks']['baremetal']['allocation_end'] = '192.168.50.200'
    end.converge(described_recipe)
  end

  before do
    stub_command("ip a show enp0s8 | grep ' 192.168.50.1/'").and_return(true)
    stub_command('ovs-vsctl show | grep br-bare').and_return(false)
    stub_command('ovs-vsctl show | grep enp0s8').and_return(false)
    stub_command('ip link show enp0s8 | grep UP').and_return(false)
    stub_command('ip addr show br-bare | grep 192.168.50.1').and_return(false)

    stub_command("      export OS_USERNAME=admin\n      export OS_PASSWORD=9NDaxGTfwRpHrL7j\n      export OS_TENANT_NAME=admin\n      export OS_AUTH_URL=http://127.0.0.1:5000/v2.0\n\n      neutron net-list -F name | egrep \"\\|[ ]+baremetal[ ]+\\|\"\n").and_return(false)
    stub_command("      export OS_USERNAME=admin\n      export OS_PASSWORD=9NDaxGTfwRpHrL7j\n      export OS_TENANT_NAME=admin\n      export OS_AUTH_URL=http://127.0.0.1:5000/v2.0\n\n      neutron subnet-list -F name | egrep \"\\|[ ]+baremetal-subnet[ ]+\\|\"\n").and_return(false)
  end

  it 'removes matching IP from interface' do
    expect(chef_run).to run_execute('remove IP from enp0s8').with(command: "ip addr del $(ip a show enp0s8 | grep ' 192.168.50.1/' | awk '{print $2}') dev enp0s8")
  end

  it 'adds a new bridge interface' do
    expect(chef_run).to run_execute('Add bridge br-bare').with(command: 'ovs-vsctl add-br br-bare')
  end

  it 'adds a port of the interface to the bridge' do
    expect(chef_run).to run_execute('Adds interface enp0s8 as port to br-bare').with(command: 'ovs-vsctl add-port br-bare enp0s8')
  end

  it 'sets the interface link up' do
    expect(chef_run).to run_execute('Sets enp0s8 link UP').with(command: 'ip link set enp0s8 up')
  end

  it 'configures IP for bridge' do
    expect(chef_run).to run_execute('Sets IP config for br-bare').with(command: 'ifconfig br-bare 192.168.50.1/24 up')
  end
end
