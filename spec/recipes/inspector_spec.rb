require 'spec_helper.rb'

describe 'ironic::inspector' do
  include ChefVault::TestFixtures.rspec_shared_context

  let(:shellout) { double('shellout', run_command: nil, stdout: '') }

  context 'defaults' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5').converge(described_recipe)
    end

    before do
      # Stub ShellOut
      allow(Mixlib::ShellOut).to receive(:new).and_return(shellout)

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
      expect(chef_run).to render_file('/etc/ironic-discoverd/dnsmasq.conf').with_content(File.read 'spec/recipes/fixtures/templates/dnsmasq.conf.default')
    end

    it 'starts and enables ironic-inspector services' do
      expect(chef_run).to start_service 'openstack-ironic-discoverd'
      expect(chef_run).to enable_service 'openstack-ironic-discoverd'
      expect(chef_run).to start_service 'openstack-ironic-discoverd-dnsmasq'
      expect(chef_run).to enable_service 'openstack-ironic-discoverd-dnsmasq'
    end
  end

  context 'overrides' do
    let(:macs_shellout) { double('macs_shellout', run_command: nil, stdout: macs_stdout) }
    let(:macs_stdout) { "00:00:00:00:00:00\n,00:00:00:00:00:01\n" }

    cached(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5').converge(described_recipe)
    end

    before do
      # Stub ShellOut
      allow(Mixlib::ShellOut).to receive(:new).with("ironic port-list | tail -n+3 | grep -v \+ | awk '{print $4}'").and_return(macs_shellout)

      # From ironic::tftp
      stub_command('[ -e /var/lib/tftpboot/var/lib/tftpboot ]').and_return(true)
    end

    it 'ignores DHCP for MACs registered in Ironic' do
      expect(chef_run).to render_file('/etc/ironic-discoverd/dnsmasq.conf').with_content(File.read 'spec/recipes/fixtures/templates/dnsmasq.conf.ignore_macs')
    end
  end
end
