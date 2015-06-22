require 'spec_helper.rb'

describe 'ironic::overrides' do
  include ChefVault::TestFixtures.rspec_shared_context

  cached(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5').converge(described_recipe)
  end

  it 'fix ironic cleaning' do
    expect(chef_run).to create_cookbook_file('/usr/lib/python2.7/site-packages/ironic/drivers/modules/agent_base_vendor.py')
  end
end
