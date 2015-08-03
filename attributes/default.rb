default['ironic']['bridges'] = {}
default['ironic']['networks'] = {}
default['ironic']['gateway'] = nil
default['ironic']['inspector']['sqlite']['path'] = '/var/lib/ironic-inspector/inspector.sqlite'
default['ironic']['inspector']['dnsmasq_interface'] = 'br-int'
default['ironic']['inspector']['add_ports'] = 'all'
default['ironic']['inspector']['keep_ports'] = 'present'
default['ironic']['inspector']['dhcp_range'] = ''
default['ironic']['inspector']['discovery_kernel'] = nil
default['ironic']['inspector']['discovery_initramfs'] = nil

default['openstack']['yum']['uri'] = 'http://repos.fedorapeople.org/repos/openstack/openstack-kilo/el7'
default['openstack']['databag_type'] = 'vault'
default['openstack']['db']['service_type'] = 'mysql'

default['openstack']['object-storage']['tempurl']['enabled'] = true

default['openstack']['object-storage']['api']['auth']['delay_auth_decision'] = true

default['openstack']['image']['api']['default_store'] = 'swift'
default['openstack']['image']['api']['stores'] = ['file', 'http', 'swift']
default['openstack']['image']['api']['swift_store_auth_version'] = 2
default['openstack']['image']['api']['swift_user_tenant'] = 'admin'
default['openstack']['image']['api']['swift_store_user'] = 'admin'
default['openstack']['image']['upload_images'] = []

default['openstack']['compute']['driver'] = 'nova.virt.ironic.IronicDriver'
default['openstack']['compute']['scheduler']['scheduler_host_manager'] = 'nova.scheduler.ironic_host_manager.IronicHostManager'
default['openstack']['compute']['config']['ram_allocation_ratio'] = '1.0'
default['openstack']['compute']['config']['reserved_host_memory_mb'] = 0
default['openstack']['compute']['network']['service_type'] = 'neutron'
default['openstack']['network']['dhcp']['enable_isolated_metadata'] = 'True'
default['openstack']['network']['dhcp']['enable_metadata_network'] = 'True'

default['openstack']['network']['dhcp']['dnsmasq_rpm_version'] = ''
default['openstack']['network']['ml2']['tenant_network_types'] = 'flat'
default['openstack']['network']['ml2']['flat_networks'] = node['ironic']['bridges'].map { |_i, b| b['phys_net'] }.join(',')
default['openstack']['network']['ml2']['network_vlan_ranges'] = node['ironic']['bridges'].map { |_i, b| b['phys_net'] }.join(',')
default['openstack']['network']['openvswitch']['bridge_mappings'] = node['ironic']['bridges'].map { |i, b| "#{b['phys_net']}:#{i}" }.join(',')

default['openstack']['bare-metal']['enabled_drivers'] = 'agent_ssh,agent_ipmitool'
default['openstack']['bare-metal']['tftp']['enabled'] = true

# Think these are needed since we are using rdo-manager-release repo for openstack-ironic
default['openstack']['compute']['platform']['package_overrides'] = '--nogpgcheck'
default['openstack']['image']['platform']['package_overrides'] = '--nogpgcheck'
default['openstack']['identity']['platform']['package_options'] = '--nogpgcheck'
default['openstack']['object-storage']['platform']['override_options'] = '--nogpgcheck' # bug of duplicate type options?
default['openstack']['object-storage']['platform']['package_overrides'] = '--nogpgcheck' # bug of duplicate type options?

# All new attributes I added
default['openstack']['bare-metal']['swift']['temp_url_duration'] = '3600'
default['openstack']['bare-metal']['swift']['container'] = 'glance'
default['openstack']['bare-metal']['swift']['account'] = ''
default['openstack']['bare-metal']['swift']['api_version'] = 'v1'
default['openstack']['bare-metal']['swift']['endpoint_url'] = ''
default['openstack']['bare-metal']['neutron']['cleaning_network_uuid'] = ''
default['openstack']['bare-metal']['api_url'] = ''
default['tftp']['flags'] = 'IPv4'
