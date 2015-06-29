require 'spec_helper.rb'

describe 'ironic::build_inspector_discovery' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5').converge(described_recipe)
  end

  it 'installs packages required for diskimage-builder' do
    expect(chef_run).to install_package 'qemu'
    expect(chef_run).to install_package 'dib-utils'
  end

  it 'installs diskimage-builder' do
    expect(chef_run).to install_package 'git'
    expect(chef_run).to sync_git '/var/tmp/diskimage-builder'
    expect(chef_run).to create_cookbook_file '/var/tmp/diskimage-builder/elements/ironic-discoverd-ramdisk/init.d/80-ironic-discoverd-ramdisk'
  end

  it 'builds a discovery ramdisk' do
    expect(chef_run).to run_execute('create discovery ramdisk')
      .with(command: 'ramdisk-image-create -o discovery fedora ironic-discoverd-ramdisk',
            cwd: '/var/tmp')
  end

  it 'installs the discovery ramdisk' do
    expect(chef_run).to run_execute('copy discovery kernel').with(command: 'cp /var/tmp/discovery.kernel /tftpboot/discovery.kernel')
    expect(chef_run).to run_execute('copy discovery initramfs').with(command: 'cp /var/tmp/discovery.initramfs /tftpboot/discovery.initramfs')
  end
end
