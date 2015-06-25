require 'spec_helper.rb'

describe 'ironic::inspector' do
  include ChefVault::TestFixtures.rspec_shared_context

  cached(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5').converge(described_recipe)
  end

  before do
    # From ironic::tftp
    stub_command('[ -e /var/lib/tftpboot/var/lib/tftpboot ]').and_return(true)
  end

  it 'installs and configured tftp server' do
    expect(chef_run).to include_recipe 'ironic::tftp'
  end

  it 'builds discovery ramdisk' do
    include_recipe 'ironic::build_inspector_discovery'
  end

  it 'configures ironic-inspector' do
    expect(chef_run).to create_template('/etc/ironic-discoverd/discoverd.conf')
    expect(chef_run).to create_template('/etc/ironic-discoverd/dnsmasq.conf')
  end

  it 'starts and enables ironic-inspector services' do
    expect(chef_run).to start_service 'openstack-ironic-discoverd'
    expect(chef_run).to enable_service 'openstack-ironic-discoverd'
    expect(chef_run).to start_service 'openstack-ironic-discoverd-dnsmasq'
    expect(chef_run).to enable_service 'openstack-ironic-discoverd-dnsmasq'
  end
end
