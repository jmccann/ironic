yum_repository 'rdo-manager-release' do
  description 'rdo-manager-release'
  baseurl 'http://trunk-mgt.rdoproject.org/repos/snapshots/latest'
  gpgcheck false
  action :create
end

package 'openstack-ironic-common' do
  options '--nogpgcheck'
end
