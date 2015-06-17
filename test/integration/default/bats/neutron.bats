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

@test 'bridge br-gate created' {
  ovs-vsctl show | grep 'Bridge br-gate'
}

@test 'enp0s3 is link UP' {
  ip link show enp0s3 | grep UP
}

@test 'Bridge br-gate has IP configured' {
  ip addr show br-gate | grep 10.0.2.15
}

@test 'baremetal net created' {
  neutron net-show baremetal
}

@test 'baremetal-subnet subnet created' {
  neutron subnet-show baremetal-subnet
}
