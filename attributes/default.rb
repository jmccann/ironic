default['openstack']['yum']['uri'] = 'http://repos.fedorapeople.org/repos/openstack/openstack-kilo/el7'
default['openstack']['databag_type'] = 'standard'
default['openstack']['db']['service_type'] = 'mysql'

default['openstack']['object-storage']['tempurl']['enabled'] = true
default['openstack']['object-storage']['auto_rebuild_rings'] = true

default['openstack']['object-storage']['object_server_chef_role']     = 'test'
default['openstack']['object-storage']['account_server_chef_role']    = 'test'
default['openstack']['object-storage']['container_server_chef_role']  = 'test'

default['openstack']['compute']['network']['service_type'] = 'neutron'
default['openstack']['network']['dhcp']['dnsmasq_rpm_version'] = ''
default['openstack']['network']['ryu']['tunnel_interface'] = 'enp0s3'
default['openstack']['network']['l3']['external_network_bridge_interface'] = 'enp0s8'

# Think these are needed since we are using rdo-manager-release repo for openstack-ironic
default['openstack']['image']['platform']['package_overrides'] = '--nogpgcheck'
default['openstack']['identity']['platform']['package_options'] = '--nogpgcheck'
default['openstack']['object-storage']['platform']['override_options'] = '--nogpgcheck' # bug of duplicate type options?
default['openstack']['object-storage']['platform']['package_overrides'] = '--nogpgcheck' # bug of duplicate type options?

default['openstack']['bare-metal']['enabled_drivers'] = 'pxe_ipmitool'
default['openstack']['bare-metal']['swift']['temp_url_duration'] = ''
default['openstack']['bare-metal']['swift']['container'] = ''
default['openstack']['bare-metal']['swift']['account'] = ''
default['openstack']['bare-metal']['swift']['api_version'] = ''
default['openstack']['bare-metal']['swift']['endpoint_url'] = ''
default['openstack']['bare-metal']['swift']['temp_url_key'] = ''
