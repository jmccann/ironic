require 'spec_helper.rb'

describe 'ironic::download_inspector_discovery' do
  context 'without checksum attribute values' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5') do |node|
        node.set['ironic']['inspector']['discovery_kernel'] = 'https://test.com/discover.kernel'
        node.set['ironic']['inspector']['discovery_initramfs'] = 'https://test.com/discover.initramfs'
      end.converge(described_recipe)
    end

    it 'downloads discovery kernel if it does not exist' do
      expect(chef_run).to create_remote_file_if_missing('/var/lib/tftpboot/discovery.kernel').with(source: 'https://test.com/discover.kernel')
    end

    it 'downloads discovery initramfs if it does not exist' do
      expect(chef_run).to create_remote_file_if_missing('/var/lib/tftpboot/discovery.initramfs').with(source: 'https://test.com/discover.initramfs')
    end
  end

  context 'with checksum attribute values' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5') do |node|
        node.set['ironic']['inspector']['discovery_kernel'] = 'https://test.com/discover.kernel'
        node.set['ironic']['inspector']['discovery_initramfs'] = 'https://test.com/discover.initramfs'
        node.set['ironic']['inspector']['discovery_kernel_checksum'] = 'abc123'
        node.set['ironic']['inspector']['discovery_initramfs_checksum'] = 'abc1234'
      end.converge(described_recipe)
    end

    it 'downloads discovery kernel' do
      expect(chef_run).to create_remote_file('/var/lib/tftpboot/discovery.kernel').with(source: 'https://test.com/discover.kernel', checksum: 'abc123')
    end

    it 'downloads discovery initramfs' do
      expect(chef_run).to create_remote_file('/var/lib/tftpboot/discovery.initramfs').with(source: 'https://test.com/discover.initramfs', checksum: 'abc1234')
    end
  end
end
