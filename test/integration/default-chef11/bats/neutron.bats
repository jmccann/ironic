#!/usr/bin/env bats

export OS_USERNAME=admin
export OS_PASSWORD=9NDaxGTfwRpHrL7j
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://10.0.2.15:5000/v2.0
export OS_REGION_NAME=RegionOne
export OS_VOLUME_API_VERSION=2

@test 'creates network mapping between br-bare and physbare' {
  grep "physbare:br-bare" /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
}

@test 'bridge br-bare created' {
  ovs-vsctl show | grep 'Bridge br-bare'
}

@test 'bridge br-bare associated with enp0s8' {
  ovs-vsctl show | grep enp0s8
}

@test 'enp0s8 is link UP' {
  ip link show enp0s8 | grep UP
}

@test 'Bridge br-bare has IP configured' {
  ip addr show br-bare | grep 192.168.50.1
}

@test 'enp0s3 is link UP' {
  ip link show enp0s3 | grep UP
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
  ip netns exec qdhcp-17f631b4-2262-4e9a-996b-887d0ef5d340 netstat -ant | grep ':80 '
}
