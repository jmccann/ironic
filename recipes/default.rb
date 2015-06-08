include_recipe 'yum::default'
package 'deltarpm'

include_recipe 'openstack-common::default'
include_recipe 'openstack-common::logging'
include_recipe 'openstack-common::set_endpoints_by_interface'
include_recipe 'openstack-common::sysctl'
include_recipe 'openstack-common::openrc'

include_recipe 'openstack-ops-database::server'
include_recipe 'openstack-ops-database::openstack-db'

include_recipe 'openstack-ops-messaging::server'

include_recipe 'openstack-identity::server'
include_recipe 'openstack-identity::registration'

include_recipe 'openstack-object-storage::common'
include_recipe 'openstack-object-storage::storage-common'
include_recipe 'ironic::block_device'
include_recipe 'ironic::account-server'
include_recipe 'ironic::container-server'
include_recipe 'ironic::object-server'
include_recipe 'openstack-object-storage::proxy-server'
include_recipe 'openstack-object-storage::client'
include_recipe 'openstack-object-storage::identity_registration'

include_recipe 'openstack-image::api'
include_recipe 'openstack-image::registry'
include_recipe 'openstack-image::identity_registration'
include_recipe 'openstack-image::image_upload'
include_recipe 'ironic::deploy_agent'

include_recipe 'openstack-network::openvswitch'
include_recipe 'openstack-network::server'
include_recipe 'openstack-network::dhcp_agent'
# include_recipe 'openstack-network::l3_agent'
include_recipe 'openstack-network::identity_registration'
include_recipe 'ironic::create_bridge'
include_recipe 'ironic::populate_neutron'

# Hacky hack to get ironic-conductor to install
include_recipe 'ironic::conductor'
include_recipe 'ironic::vbox_driver_prereq'
include_recipe 'ironic::tftp'

include_recipe 'ironic::ironic_overrides'
include_recipe 'openstack-bare-metal::conductor'
include_recipe 'openstack-bare-metal::api'
# Contribute attributizing: enabled-drivers, swift
r = resources('template[/etc/ironic/ironic.conf]')
r.cookbook 'ironic'
include_recipe 'openstack-bare-metal::identity_registration'

include_recipe 'openstack-compute::nova-setup'
include_recipe 'openstack-compute::client'
include_recipe 'openstack-compute::scheduler'
include_recipe 'openstack-compute::api-metadata'
include_recipe 'openstack-compute::conductor'
include_recipe 'openstack-compute::compute'
include_recipe 'openstack-compute::api-os-compute'
include_recipe 'openstack-compute::identity_registration'
