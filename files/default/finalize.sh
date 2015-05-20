#!/bin/bash

# Source creds
. ~/devstack/openrc admin admin

# Setup networking
sed -i -r -e 's/^type_drivers = .*/type_drivers = flat/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^mechanism_drivers = .*/mechanism_drivers = openvswitch/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^tenant_network_types = .*/tenant_network_types = flat/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^# flat_networks =.*/flat_networks = physnet1/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^# network_vlan_ranges =.*/network_vlan_ranges = physnet1/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^# enable_security_group =.*/enable_security_group = True/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^\[ovs\]/\[ovs\]\nbridge_mappings = physnet1:br-eth1/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^\[ovs\]/\[ovs\]\nbridge_mappings = physnet1:br-eth1/g' /opt/stack/neutron/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini

sudo ovs-vsctl add-br br-eth1
sudo ovs-vsctl add-port br-eth1 eth1

# Restart Open vSwitch agent (#9 q-agt)
# script /dev/null
screen -S stack -X at 9 stuff $'\003' # Ctrl-C
screen -S stack -X at 9 stuff $'\033[A' # Up arrow (for prev command)
screen -S stack -X at 9 stuff $'\015' # Enter

# Create new net and subnet
TENANT_ID=admin
NETWORK_CIDR=192.168.50.0/24
SUBNET_NAME=barenet
GATEWAY_IP=192.168.50.1
START_IP=192.168.50.100
END_IP=192.168.50.200

neutron net-create --tenant-id $TENANT_ID sharednet1 --shared \
--provider:network_type flat --provider:physical_network physnet1

neutron subnet-create sharednet1 $NETWORK_CIDR --name $SUBNET_NAME \
--ip-version=4 --gateway=$GATEWAY_IP --allocation-pool \
start=$START_IP,end=$END_IP --enable-dhcp

# Some interface config cleanup
sudo ifconfig eth1 up
sudo ifconfig br-eth1 192.168.50.1 netmask 255.255.255.0 up

# Create a new node in ironic
IMG_SRC=$(glance image-list | egrep 'uec ' | awk '{print $2}')
IMG_KERN=$(glance image-list | egrep 'uec-kernel ' | awk '{print $2}')
IMG_RAM=$(glance image-list | egrep 'uec-ramdisk ' | awk '{print $2}')
MAC_ADDRESS='08:00:27:6E:DF:70' # Set from baremetal_vm.sh

RAM_MB=2048
CPU=1
DISK_GB=11
ARCH=x86_64

NODE_UUID=$(ironic node-create -n my-baremetal -d pxe_vbox -i virtualbox_host='10.0.2.2' -i virtualbox_vmname='baremetal' | grep uuid | awk '{print $4}' | head -1)

ironic node-update $NODE_UUID add \
properties/cpus=$CPU \
properties/memory_mb=$RAM_MB \
properties/local_gb=$DISK_GB \
properties/cpu_arch=$ARCH

ironic node-update $NODE_UUID add instance_info/root_gb=11
ironic node-update $NODE_UUID add instance_info/image_source=$IMG_SRC
ironic node-update $NODE_UUID add driver_info/deploy_kernel=$IMG_KERN
ironic node-update $NODE_UUID add driver_info/deploy_ramdisk=$IMG_RAM

ironic port-create -n $NODE_UUID -a $MAC_ADDRESS

# Create new flavor in nova for baremetal
RAM_MB=2048
CPU=1
DISK_GB=11
ARCH=x86_64
IMG_KERN=$(glance image-list | egrep 'uec-kernel ' | awk '{print $2}')
IMG_RAM=$(glance image-list | egrep 'uec-ramdisk ' | awk '{print $2}')

nova flavor-create my-baremetal-flavor auto $RAM_MB $DISK_GB $CPU
nova flavor-key my-baremetal-flavor set cpu_arch=$ARCH
