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
# package 'python-ZSI'
# execute 'pip install pyremotevbox'

execute '/var/tmp/devstack/tools/create-stack-user.sh' do
  not_if 'egrep "^[ \t]*stack:" /etc/passwd'
end

execute 'git clone https://github.com/openstack-dev/devstack.git devstack' do
  cwd '/opt/stack'
  user 'stack'
  not_if '[ -d devstack ]'
end

cookbook_file '/opt/stack/devstack/local.conf'

# Want to stack automatically but sudo tty issues?  But another cookbook does it fine ...
# execute 'unstack.sh' do
#   cwd '/opt/stack/devstack'
#   command '/opt/stack/devstack/unstack.sh'
#   user 'stack'
# end
#
# execute 'stack.sh' do
#   cwd '/opt/stack/devstack'
#   command '/opt/stack/devstack/stack.sh'
#   user 'stack'
# end
