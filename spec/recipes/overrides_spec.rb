require 'spec_helper.rb'

describe 'ironic::overrides' do
  include ChefVault::TestFixtures.rspec_shared_context

  context 'default attribute values' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5').converge(described_recipe)
    end

    it 'disables node cleaning when no cleaning network specificed' do
      expect(chef_run).to render_file('/etc/ironic/ironic.conf').with_content('clean_nodes = false')
    end

    it 'fix ironic cleaning' do
      expect(chef_run).to create_cookbook_file('/usr/lib/python2.7/site-packages/ironic/drivers/modules/agent_base_vendor.py')
    end
  end

  context 'user attribute values' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5') do |node, _server|
        node.set['openstack']['bare-metal']['neutron']['cleaning_network_uuid'] = 'asdf'
      end.converge(described_recipe)
    end

    it 'enables node cleaning when cleaning network specified' do
      expect(chef_run).to render_file('/etc/ironic/ironic.conf').with_content('clean_nodes = true')
      expect(chef_run).to render_file('/etc/ironic/ironic.conf').with_content('cleaning_network_uuid = asdf')
    end
  end
end
