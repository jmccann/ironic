require 'spec_helper'

describe 'ironic::populate_neutron' do
  include ChefVault::TestFixtures.rspec_shared_context

  cached(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5', step_into: ['rhel_network_interface']) do |node, _server|
      node.set['ironic']['gateway'] = '10.0.2.2'

      node.set['ironic']['bridges']['br-bare']['interface'] = 'enp0s8'
      node.set['ironic']['bridges']['br-bare']['phys_net'] = 'physbare'
      node.set['ironic']['bridges']['br-bare']['ip'] = '192.168.50.1'
      node.set['ironic']['bridges']['br-bare']['mask'] = '24'
      node.set['ironic']['bridges']['br-gate']['interface'] = 'enp0s3'
      node.set['ironic']['bridges']['br-gate']['phys_net'] = 'physgate'
      node.set['ironic']['bridges']['br-gate']['ip'] = '10.0.2.15'
      node.set['ironic']['bridges']['br-gate']['mask'] = '24'

      node.set['ironic']['networks']['baremetal']['phys_net'] = 'physbare'
      node.set['ironic']['networks']['baremetal']['network'] = '192.168.50.0'
      node.set['ironic']['networks']['baremetal']['gateway'] = '192.168.50.1'
      node.set['ironic']['networks']['baremetal']['mask'] = '24'
      node.set['ironic']['networks']['baremetal']['allocation_start'] = '192.168.50.100'
      node.set['ironic']['networks']['baremetal']['allocation_end'] = '192.168.50.200'

      node.set['ironic']['networks']['test']['phys_net'] = 'physbare'
      node.set['ironic']['networks']['test']['network'] = '192.168.55.0'
      node.set['ironic']['networks']['test']['mask'] = '24'
      node.set['ironic']['networks']['test']['allocation_start'] = '192.168.55.100'
      node.set['ironic']['networks']['test']['allocation_end'] = '192.168.55.200'
    end.converge(described_recipe)
  end

  before do
    stub_command("ip a show enp0s8 | grep ' 192.168.50.1/24'").and_return(true)
    stub_command("ovs-vsctl show | grep 'Bridge br-bare'").and_return(false)
    stub_command('ovs-vsctl show | grep enp0s8').and_return(false)
    stub_command('ip link show enp0s8 | grep UP').and_return(false)
    stub_command('ip link show br-bare | grep UP').and_return(false)
    stub_command('ip addr show br-bare | grep 192.168.50.1').and_return(false)

    stub_command("ip a show enp0s3 | grep ' 10.0.2.15/24'").and_return(true)
    stub_command("ovs-vsctl show | grep 'Bridge br-gate'").and_return(false)
    stub_command('ovs-vsctl show | grep enp0s3').and_return(false)
    stub_command('ip link show enp0s3 | grep UP').and_return(false)
    stub_command('ip link show br-gate | grep UP').and_return(false)
    stub_command('ip addr show br-gate | grep 10.0.2.15').and_return(false)

    stub_command("route -n | awk '{print $1}' | grep '0.0.0.0'").and_return(false)
    stub_command("      export OS_USERNAME=admin\n      export OS_PASSWORD=9NDaxGTfwRpHrL7j\n      export OS_TENANT_NAME=admin\n      export OS_AUTH_URL=http://127.0.0.1:5000/v2.0\n\n      neutron net-list -F name | egrep \"\\|[ ]+baremetal[ ]+\\|\"\n").and_return(false)
    stub_command("      export OS_USERNAME=admin\n      export OS_PASSWORD=9NDaxGTfwRpHrL7j\n      export OS_TENANT_NAME=admin\n      export OS_AUTH_URL=http://127.0.0.1:5000/v2.0\n\n      neutron subnet-list -F name | egrep \"\\|[ ]+baremetal-subnet[ ]+\\|\"\n").and_return(false)
    stub_command("      export OS_USERNAME=admin\n      export OS_PASSWORD=9NDaxGTfwRpHrL7j\n      export OS_TENANT_NAME=admin\n      export OS_AUTH_URL=http://127.0.0.1:5000/v2.0\n\n      neutron net-list -F name | egrep \"\\|[ ]+test[ ]+\\|\"\n").and_return(false)
    stub_command("      export OS_USERNAME=admin\n      export OS_PASSWORD=9NDaxGTfwRpHrL7j\n      export OS_TENANT_NAME=admin\n      export OS_AUTH_URL=http://127.0.0.1:5000/v2.0\n\n      neutron subnet-list -F name | egrep \"\\|[ ]+test-subnet[ ]+\\|\"\n").and_return(false)
  end

  it 'removes matching IP from interface' do
    expect(chef_run).to run_execute('remove IP from enp0s8').with(command: 'ip addr del 192.168.50.1/24 dev enp0s8')
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
    expect(chef_run).to run_execute('Sets IP config for br-bare').with(command: 'ip addr add 192.168.50.1/24 dev br-bare')
  end

  it 'configures default gateway' do
    expect(chef_run).to run_execute('set default gateway').with(command: 'route add default gw 10.0.2.2')
  end

  it 'adds neutron net baremetal' do
    expect(chef_run).to run_execute('create baremetal net').with(command: 'neutron net-create baremetal --shared --provider:network_type flat --provider:physical_network physbare')
  end

  it 'adds neutron subnet baremetal-subnet' do
    expect(chef_run).to run_execute('create baremetal subnet').with(command: 'neutron subnet-create baremetal 192.168.50.0/24 --name baremetal-subnet --ip-version=4 --gateway=192.168.50.1 --allocation-pool start=192.168.50.100,end=192.168.50.200 --enable-dhcp')
  end

  it 'adds neutron subnet test-subnet' do
    expect(chef_run).to run_execute('create test subnet').with(command: 'neutron subnet-create test 192.168.55.0/24 --name test-subnet --ip-version=4 --gateway= --allocation-pool start=192.168.55.100,end=192.168.55.200 --enable-dhcp')
  end
end
