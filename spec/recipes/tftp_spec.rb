require 'spec_helper.rb'

describe 'ironic::tftp' do
  include ChefVault::TestFixtures.rspec_shared_context

  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5').converge(described_recipe)
  end

  before do
    stub_command('[ -e /var/lib/tftpboot/var/lib/tftpboot ]').and_return(false)
  end

  it 'installs syslinux files' do
    expect(chef_run).to install_package 'syslinux-tftpboot'
  end

  it 'installs and configures a basic tftp server' do
    include_recipe 'tftp::server'
  end

  it 'sets ironic as owner of tftp directory' do
    expect(chef_run).to create_directory('/var/lib/tftpboot').with(owner: 'ironic', group: 'ironic')
  end

  it 'creates pxelinux.cfg directory in tftp directory' do
    expect(chef_run).to create_directory('/var/lib/tftpboot/pxelinux.cfg').with(owner: 'ironic', group: 'ironic', mode: 0755)
  end

  it 'sets fake absolute path inside tftp chroot' do
    expect(chef_run).to create_directory '/var/lib/tftpboot/var/lib'
    expect(chef_run).to run_execute('ln -s ../.. tftpboot').with(cwd: '/var/lib/tftpboot/var/lib')
  end
end
