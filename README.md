Ironic
======

# Setup the stack
```
kitchen conv
kitchen login
sudo su - stack
cd devstack
./stack.sh
```

Now wait about 30 min.

When it is done you can hit the dashboard @ http://localhost:8080/ admin:password

# Start VBox Webserver thing on host
Blank out password:
```
VBoxManage setproperty websrvauthlibrary null
```

Start it up in foreground
MacOSX:
```
/Applications/VirtualBox.app/Contents/MacOS/vboxwebsrv
```

Windows:
```
C:\Program Files\Oracle\VirtualBox\VBoxWebSrv.exe
```

# Special OS configs for vbox baremetal

## Configure network
```
sed -i -r -e 's/^type_drivers = .*/type_drivers = flat/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^mechanism_drivers = .*/mechanism_drivers = openvswitch/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^tenant_network_types = .*/tenant_network_types = flat/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^# flat_networks =.*/flat_networks = physnet1/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^# network_vlan_ranges =.*/network_vlan_ranges = physnet1/g' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -r -e 's/^# enable_security_group =.*/enable_security_group = True/g' /etc/neutron/plugins/ml2/ml2_conf.ini
```

Add `bridge_mappings = physnet1:br-eth1` to `[ovs]` section in `/etc/neutron/plugins/ml2/ml2_conf.ini`.

Add `bridge_mappings = physnet1:br-eth1` to `[ovs]` section in `/opt/stack/neutron/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini` also.

```
sudo ovs-vsctl add-br br-eth1
sudo ovs-vsctl add-port br-eth1 eth1
```

```
script /dev/null
screen -r
```

Goto `q-agt`, do a `Ctrl+C` to end Open vSwitch agent.  Then hit the up arrow and Enter to run the last command which starts it again.  `Ctrl+d a` to detach from screen.

Create new net and subnet with:

```
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
```

```
sudo ifconfig eth1 up
sudo ifconfig br-eth1 192.168.50.1 netmask 255.255.255.0 up
```

# Create node
On Host:
```
./baremetal_vm.sh
```

In cloud-controller:
```
IMG_SRC=$(glance image-list | egrep 'uec ' | awk '{print $2}')
IMG_KERN=$(glance image-list | egrep 'uec-kernel ' | awk '{print $2}')
IMG_RAM=$(glance image-list | egrep 'uec-ramdisk ' | awk '{print $2}')
MAC_ADDRESS='08:00:27:6E:DF:70' # This is probably different ... could update baremetal_vm to set it to something known

RAM_MB=2048
CPU=1
DISK_GB=11
ARCH=x86_64

NODE_UUID=$(ironic node-create -d pxe_vbox -i virtualbox_host='10.0.2.2' -i virtualbox_vmname='baremetal' | grep uuid | awk '{print $4}' | head -1)

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

ironic node-show $NODE_UUID
ironic node-validate $NODE_UUID
```

# Create new baremetal flavor

```
RAM_MB=2048
CPU=1
DISK_GB=11
ARCH={i686|x86_64}
IMG_KERN=$(glance image-list | egrep 'uec-kernel ' | awk '{print $2}')
IMG_RAM=$(glance image-list | egrep 'uec-ramdisk ' | awk '{print $2}')

nova flavor-create my-baremetal-flavor auto $RAM_MB $DISK_GB $CPU
nova flavor-key my-baremetal-flavor set cpu_arch=$ARCH
```

# Boot an instance to the node

```
source ~/devstack/openrc admin admin
image=$(nova image-list | egrep "$DEFAULT_IMAGE_NAME"'[^-]' | awk '{ print $2 }')
ssh-keygen
```

```
nova keypair-add default --pub-key ~/.ssh/id_rsa.pub
```

```
IMG_SRC=$(glance image-list | egrep 'uec ' | awk '{print $2}')

ironic node-update $NODE_UUID add instance_info/root_gb=11
ironic node-update $NODE_UUID add instance_info/image_source=$IMG_SRC

net_id=$(neutron net-list | egrep "sharednet1"'[^-]' | awk '{ print $2 }')
nova boot --flavor my-baremetal-flavor --nic net-id=$net_id --image $image --key-name default testing
```

# Resources

* http://docs.openstack.org/developer/ironic/drivers/vbox.html - Using Vbox to simulate baremetal nodes for ironic.  This assumes a base undertanding of how a lot of stuff works already.
* http://docs.openstack.org/developer/ironic/dev/dev-quickstart.html#deploying-ironic-with-devstack - Where I started.  Has a good walkthrough of EASILY setting it up and working with 3 kvm 'baremetal' hosts.
* http://docs.openstack.org/developer/ironic/deploy/install-guide.html - Had additional notes for creating baremetal nodes in ironic ... details missing in other guides above.
* https://www.rdoproject.org/Networking_in_too_much_detail - Crazy in depth info on how networking works in Openstack
* https://software.intel.com/en-us/articles/physical-server-provisioning-with-openstack - More misc references
