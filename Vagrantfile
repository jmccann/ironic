# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.define 'ironc' do |ironc|
    # Set hostname
    ironc.vm.hostname = 'cloud-controller'

    # Every Vagrant virtual environment requires a box to build off of
    # ironc.vm.box = 'chef/fedora-20'
    ironc.vm.box = 'chef/ubuntu-14.04'

    # The url from where the 'config.vm.box' box will be fetched if it
    # doesn't already exist on the user's system
    # ironc.vm.box_url = 'chef/fedora-20'
    ironc.vm.box_url = 'chef/ubuntu-14.04'

    config.vm.provider 'virtualbox' do |v|
      v.memory = 8096
      v.cpus = 2
    end

    ironc.vm.network 'forwarded_port', guest: 80, host: 8080
    ironc.vm.network 'forwarded_port', guest: 443, host: 4443
    ironc.vm.network 'private_network', ip: '192.168.50.4', virtualbox__intnet: true, auto_config: false

    # Install Chef
    ironc.omnibus.chef_version = 'latest'

    # Enabling the Berkshelf plugin
    ironc.berkshelf.enabled = true

    # Chef run to create things
    ironc.vm.provision :chef_solo do |chef|
      chef.add_recipe 'ironic::default'
    end
  end
end
