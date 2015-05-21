include_recipe 'apt::default'
include_recipe 'git::default'

git '/var/tmp/devstack' do
  repository 'https://github.com/openstack-dev/devstack.git'
  action :sync
end

# Correct dependency issues I ran into on Fedora
# package 'bridge-utils'
# package 'vim-minimal' do
#   action :upgrade
# end
include_recipe 'ironic::vbox_driver_prereq'

execute '/var/tmp/devstack/tools/create-stack-user.sh' do
  not_if 'egrep "^[ \t]*stack:" /etc/passwd'
end

execute "ssh-keygen -N '' -f /opt/stack/.ssh/id_rsa" do
  creates '/opt/stack/.ssh/id_rsa'
  user 'stack'
end

execute 'git clone https://github.com/openstack-dev/devstack.git devstack' do
  cwd '/opt/stack'
  user 'stack'
  not_if '[ -d devstack ]'
end

template '/opt/stack/devstack/local.conf'
template '/opt/stack/finalize.sh' do
  user 'stack'
  mode 0750
end

# Want to stack automatically but sudo tty issues?  But another cookbook does it fine ...
# execute 'unstack.sh' do
#   cwd '/opt/stack/devstack'
#   command '/opt/stack/devstack/unstack.sh'
#   user 'stack'
# end

execute 'stack.sh' do
  cwd '/opt/stack/devstack'
  command '/opt/stack/devstack/stack.sh && touch /opt/stack/devstack/.stacked'
  user 'stack'
  environment 'HOME' => '/opt/stack'
  timeout 7200
  creates '/opt/stack/devstack/.stacked'
end

execute 'finalize.sh' do
  cwd '/opt/stack'
  user 'stack'
  command '/opt/stack/finalize.sh && touch /opt/stack/.finalized'
  creates '/opt/stack/.finalized'
end
