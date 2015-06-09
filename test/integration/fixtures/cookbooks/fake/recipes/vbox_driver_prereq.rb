include_recipe 'yum::default'
include_recipe 'yum-epel::default'

package 'python-pip'

execute 'pip install pyremotevbox' do
  not_if 'pip list | grep pyremotevbox'
end
