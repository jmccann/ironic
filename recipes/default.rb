include_recipe 'yum::default'

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

include_recipe 'openstack-image::api'
include_recipe 'openstack-image::registry'
include_recipe 'openstack-image::identity_registration'
include_recipe 'openstack-image::image_upload'

# Hacky hack to get ironic-conductor to install
include_recipe 'ironic::conductor'

include_recipe 'openstack-bare-metal::conductor'
include_recipe 'openstack-bare-metal::api'
include_recipe 'openstack-bare-metal::identity_registration'
