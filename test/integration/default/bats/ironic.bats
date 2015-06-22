#!/usr/bin/env bats

export OS_USERNAME=admin
export OS_PASSWORD=9NDaxGTfwRpHrL7j
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://10.0.2.15:5000/v2.0
export OS_REGION_NAME=RegionOne
export OS_VOLUME_API_VERSION=2

@test 'fix cleaning nodes' {
  grep "LOG.debug('Last Command: %s.', last_command)" /usr/lib/python2.7/site-packages/ironic/drivers/modules/agent_base_vendor.py
}
