default['openstack']['yum']['uri'] = 'http://repos.fedorapeople.org/repos/openstack/openstack-kilo/el7'
default['openstack']['databag_type'] = 'standard'
default['openstack']['db']['service_type'] = 'mysql'

# Think these are needed since we are using rdo-manager-release repo for openstack-ironic
default['openstack']['image']['platform']['package_overrides'] = '--nogpgcheck'
default['openstack']['identity']['platform']['package_options'] = '--nogpgcheck'
