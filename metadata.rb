name             'ironic'
maintainer       'Jacob McCann'
maintainer_email 'jacob.mccann2@target.com'
license          'Apache 2.0'
description      'A cookbook for deploying Hanlon'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '4.3.0'

depends 'yum'
depends 'tftp'
depends 'chef-vault', '1.3.0'
depends 'openstack-common'
depends 'openstack-ops-database'
depends 'openstack-ops-messaging'
depends 'openstack-identity'
depends 'openstack-bare-metal'
depends 'openstack-image'
depends 'openstack-object-storage'
depends 'openstack-network'
depends 'openstack-compute'
