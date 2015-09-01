include_recipe 'kvm::host'

service 'libvirtd' do
  action [:enable, :start]
end

directory '/root/scripts'
directory '/root/templates'

%w(create-node setup-network configure-vm).each do |f|
  cookbook_file "/root/scripts/#{f}" do
    mode 0750
  end
end

%w(brbm.xml vm.xml).each do |f|
  cookbook_file "/root/templates/#{f}" do
    mode 0640
  end
end
