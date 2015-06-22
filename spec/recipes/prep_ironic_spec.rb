require 'spec_helper.rb'

describe 'ironic::prep_ironic' do
  include ChefVault::TestFixtures.rspec_shared_context

  cached(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5') do |node|
    end.converge(described_recipe)
  end

  it 'gets swift auth' do
    expect(chef_run).to run_ruby_block('Get swift auth')
  end

  it 'gets cleaning network id' do
    expect(chef_run).to run_ruby_block('Get cleaning network id')
  end

  it 'installs ipmitool' do
    expect(chef_run).to install_package('ipmitool')
  end
end
