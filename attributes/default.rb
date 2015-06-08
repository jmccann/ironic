default['openstack']['yum']['uri'] = 'http://repos.fedorapeople.org/repos/openstack/openstack-kilo/el7'
default['openstack']['databag_type'] = 'standard'
default['openstack']['db']['service_type'] = 'mysql'

default['openstack']['object-storage']['tempurl']['enabled'] = true

default['openstack']['object-storage']['object_server_chef_role']     = 'test'
default['openstack']['object-storage']['account_server_chef_role']    = 'test'
default['openstack']['object-storage']['container_server_chef_role']  = 'test'
default['openstack']['object-storage']['api']['auth']['delay_auth_decision'] = true

default['openstack']['image']['api']['default_store'] = 'swift'
default['openstack']['image']['api']['stores'] = ['file', 'http', 'swift']
default['openstack']['image']['api']['swift_store_auth_address'] = 'http://10.0.2.15:5000/v2.0'
default['openstack']['image']['api']['swift_store_auth_version'] = 2
default['openstack']['image']['api']['swift_user_tenant'] = 'admin'
default['openstack']['image']['api']['swift_store_user'] = 'admin'
default['openstack']['image']['upload_images'] = []

default['openstack']['compute']['driver'] = 'nova.virt.ironic.IronicDriver'
default['openstack']['compute']['scheduler']['scheduler_host_manager'] = 'nova.scheduler.ironic_host_manager.IronicHostManager'
default['openstack']['compute']['config']['ram_allocation_ratio'] = '1.0'
default['openstack']['compute']['config']['reserved_host_memory_mb'] = 0
default['openstack']['compute']['network']['service_type'] = 'neutron'

default['openstack']['network']['dhcp']['dnsmasq_rpm_version'] = ''
default['openstack']['network']['ml2']['tenant_network_types'] = 'flat'
default['openstack']['network']['ml2']['flat_networks'] = 'physbare'
default['openstack']['network']['ml2']['network_vlan_ranges'] = 'physbare'
default['openstack']['network']['openvswitch']['bridge_mappings'] = 'physbare:br-bare'

# Think these are needed since we are using rdo-manager-release repo for openstack-ironic
default['openstack']['compute']['platform']['package_overrides'] = '--nogpgcheck'
default['openstack']['image']['platform']['package_overrides'] = '--nogpgcheck'
default['openstack']['identity']['platform']['package_options'] = '--nogpgcheck'
default['openstack']['object-storage']['platform']['override_options'] = '--nogpgcheck' # bug of duplicate type options?
default['openstack']['object-storage']['platform']['package_overrides'] = '--nogpgcheck' # bug of duplicate type options?

default['openstack']['bare-metal']['tftp']['enabled'] = true
default['openstack']['bare-metal']['enabled_drivers'] = 'pxe_ipmitool'
default['openstack']['bare-metal']['swift']['temp_url_duration'] = ''
default['openstack']['bare-metal']['swift']['container'] = ''
default['openstack']['bare-metal']['swift']['account'] = ''
default['openstack']['bare-metal']['swift']['api_version'] = ''
default['openstack']['bare-metal']['swift']['endpoint_url'] = ''
default['openstack']['bare-metal']['swift']['temp_url_key'] = ''
default['openstack']['bare-metal']['neutron']['cleaning_network_uuid'] = ''
default['openstack']['bare-metal']['api_url'] = ''
default['tftp']['flags'] = 'IPv4'
