name             'ironic'
maintainer       'Jacob McCann'
maintainer_email 'jacob.mccann2@target.com'
license          'Apache 2.0'
description      'A cookbook for deploying Hanlon'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'yum'
depends 'openstack-common'
depends 'openstack-ops-database'
depends 'openstack-ops-messaging'
depends 'openstack-identity'
depends 'openstack-bare-metal'
