package 'curl'

execute '/var/tmp/devstack/tools/install_pip.sh' do
  creates '/usr/local/bin/pip'
end

package 'python-ZSI'

execute '/usr/local/bin/pip install pyremotevbox' do
  not_if '/usr/local/bin/pip list | grep pyremotevbox'
end
