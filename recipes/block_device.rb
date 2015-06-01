package 'xfsprogs' do
  options '--nogpgcheck'
  action :upgrade
end

%w(parted util-linux).each do |pkg|
  package pkg do
    options '--nogpgcheck'
    action :upgrade
  end
end

execute 'Create block file' do
  command 'truncate -s 6G /var/tmp/swift_dev'
  creates '/var/tmp/swift_dev'
end

file '/var/tmp/swift_dev' do
  user 'swift'
  group 'swift'
end

execute 'Put FS on block file' do
  command 'mkfs.xfs -f -i size=1024 /var/tmp/swift_dev'
  not_if 'file -sL /var/tmp/swift_dev | grep XFS'
end

directory '/srv/node/sdb1' do
  owner 'swift'
  group 'swift'
  recursive true
end

mount '/srv/node/sdb1' do
  device '/var/tmp/swift_dev'
  fstype 'xfs'
  options 'loop,noatime,nodiratime,nobarrier,logbufs=8'
  pass 0
  action [:mount, :enable]
end

execute 'chown -R swift.swift /srv/node/sdb1' do
  not_if '[ "$(stat -c %U /srv/node/sdb1)" == "swift" '
end

execute 'swift-ring-builder account.builder create 9 1 1' do
  cwd '/etc/swift'
  user 'swift'
  creates '/etc/swift/account.builder'
  notifies :run, 'execute[Add to account.builder]', :immediately
end

execute 'swift-ring-builder container.builder create 9 1 1' do
  cwd '/etc/swift'
  user 'swift'
  creates '/etc/swift/container.builder'
  notifies :run, 'execute[Add to container.builder]', :immediately
end

execute 'swift-ring-builder object.builder create 9 1 1' do
  cwd '/etc/swift'
  user 'swift'
  creates '/etc/swift/object.builder'
  notifies :run, 'execute[Add to object.builder]', :immediately
end

execute 'Add to object.builder' do
  cwd '/etc/swift'
  user 'swift'
  command 'swift-ring-builder object.builder add z1-127.0.0.1:6000/sdb1 1'
  action :nothing
end
execute 'Add to container.builder' do
  cwd '/etc/swift'
  user 'swift'
  command 'swift-ring-builder container.builder add z1-127.0.0.1:6001/sdb1 1'
  action :nothing
end
execute 'Add to account.builder' do
  cwd '/etc/swift'
  user 'swift'
  command 'swift-ring-builder account.builder add z1-127.0.0.1:6002/sdb1 1'
  action :nothing
end

execute 'swift-ring-builder object.builder rebalance' do
  cwd '/etc/swift'
  user 'swift'
  creates '/etc/swift/object.ring.gz'
end
execute 'swift-ring-builder container.builder rebalance' do
  cwd '/etc/swift'
  user 'swift'
  creates '/etc/swift/container.ring.gz'
end
execute 'swift-ring-builder account.builder rebalance' do
  cwd '/etc/swift'
  user 'swift'
  creates '/etc/swift/account.ring.gz'
end
