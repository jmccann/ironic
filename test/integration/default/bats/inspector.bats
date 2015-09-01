#!/usr/bin/env bats

@test 'inspector is installed' {
  rpm -q openstack-ironic-discoverd
}

@test 'inspector is configured' {
  grep 'os_auth_url = http://10.0.2.15:5000/v2.0' /etc/ironic-discoverd/discoverd.conf
}

@test 'inspector dnsmasq is configured' {
  grep brbm /etc/ironic-discoverd/dnsmasq.conf
}

@test 'inspector is running' {
  systemctl status openstack-ironic-discoverd | egrep 'Active: active'
  systemctl status openstack-ironic-discoverd-dnsmasq | egrep 'Active: active'
}

@test 'discovery ramdisk is created' {
  [ -s /var/lib/tftpboot/discovery.initramfs ]
  [ -s /var/lib/tftpboot/discovery.kernel ]
}

@test 'default pxe config generated' {
  [ -s /var/lib/tftpboot/pxelinux.cfg/default ]
}

@test 'discovery ramdisk is accessbile via tftp' {
  curl tftp://10.0.2.15/discovery.kernel
  curl tftp://10.0.2.15/discovery.initramfs
}
