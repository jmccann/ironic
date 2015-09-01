#!/usr/bin/env bats

export OS_USERNAME=admin
export OS_PASSWORD=9NDaxGTfwRpHrL7j
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://10.0.2.15:5000/v2.0
export OS_REGION_NAME=RegionOne
export OS_VOLUME_API_VERSION=2

@test 'creates network mapping between br-bare and physbare' {
  grep "physbare:brbm" /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
}

@test 'baremetal net created' {
  neutron net-show baremetal
}

@test 'baremetal-subnet subnet created' {
  neutron subnet-show baremetal-subnet
}

@test 'baremetal-subnet has gateway set' {
  neutron subnet-show baremetal-subnet | grep gateway_ip | grep 192.168.50.1
}

@test 'metadata service is configured' {
  namespace=$(ip netns | head -n1)
  # IP is configured in network namespace
  ip netns exec $namespace ip a | grep '169.254.169.254'

  # Listening on port 80
  ip netns exec $namespace netstat -ant | grep ':80 '
}
