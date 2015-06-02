default['openstack']['yum']['uri'] = 'http://repos.fedorapeople.org/repos/openstack/openstack-kilo/el7'
default['openstack']['databag_type'] = 'standard'
default['openstack']['db']['service_type'] = 'mysql'

default['openstack']['object-storage']['tempurl']['enabled'] = true
default['openstack']['object-storage']['auto_rebuild_rings'] = true

default['openstack']['object-storage']['object_server_chef_role']     = 'test'
default['openstack']['object-storage']['account_server_chef_role']    = 'test'
default['openstack']['object-storage']['container_server_chef_role']  = 'test'

default['openstack']['compute']['driver'] = 'nova.virt.ironic.IronicDriver'
default['openstack']['compute']['scheduler']['scheduler_host_manager'] = 'nova.scheduler.ironic_host_manager.IronicHostManager'
default['openstack']['compute']['config']['ram_allocation_ratio'] = '1.0'
default['openstack']['compute']['config']['reserved_host_memory_mb'] = 0
default['openstack']['compute']['network']['service_type'] = 'neutron'

default['openstack']['network']['dhcp']['dnsmasq_rpm_version'] = ''
default['openstack']['network']['ml2']['tenant_network_types'] = 'flat'
default['openstack']['network']['ml2']['network_vlan_ranges'] = 'physbaremetal'
default['openstack']['network']['openvswitch']['bridge_mappings'] = 'physbaremetal:br-ex'

# Think these are needed since we are using rdo-manager-release repo for openstack-ironic
default['openstack']['compute']['platform']['package_overrides'] = '--nogpgcheck'
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
default['openstack']['bare-metal']['neutron']['cleaning_network_uuid'] = ''
