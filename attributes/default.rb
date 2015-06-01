default['openstack']['yum']['uri'] = 'http://repos.fedorapeople.org/repos/openstack/openstack-kilo/el7'
default['openstack']['databag_type'] = 'standard'
default['openstack']['db']['service_type'] = 'mysql'

default['openstack']['object-storage']['tempurl']['enabled'] = true
default['openstack']['object-storage']['auto_rebuild_rings'] = true

default['openstack']['object-storage']['object_server_chef_role']     = 'test'
default['openstack']['object-storage']['account_server_chef_role']    = 'test'
default['openstack']['object-storage']['container_server_chef_role']  = 'test'

# Think these are needed since we are using rdo-manager-release repo for openstack-ironic
default['openstack']['image']['platform']['package_overrides'] = '--nogpgcheck'
default['openstack']['identity']['platform']['package_options'] = '--nogpgcheck'
default['openstack']['object-storage']['platform']['override_options'] = '--nogpgcheck' # bug of duplicate type options?
default['openstack']['object-storage']['platform']['package_overrides'] = '--nogpgcheck' # bug of duplicate type options?
