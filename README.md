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

# Create vbox baremetal node
On Host:
```
./baremetal_vm.sh
```

# Run prep script

```
/opt/stack/finalize.sh
```

# Verify stuff

```
NODE_UUID=$(ironic node-list | egrep "my-baremetal"'[^-]' | awk '{ print $2 }')
ironic node-show $NODE_UUID
ironic node-validate $NODE_UUID
```

# Boot an instance to the node

```
source ~/devstack/openrc admin admin
nova keypair-add default --pub-key ~/.ssh/id_rsa.pub
image=$(nova image-list | egrep "$DEFAULT_IMAGE_NAME"'[^-]' | awk '{ print $2 }')

ironic node-update $NODE_UUID add instance_info/root_gb=11
ironic node-update $NODE_UUID add instance_info/image_source=$image

net_id=$(neutron net-list | egrep "sharednet1"'[^-]' | awk '{ print $2 }')
nova boot --flavor my-baremetal-flavor --nic net-id=$net_id --image $image --key-name default testing
```

Can take up to like 10 sec before VM will auto power-on.  Be patient.

# Resources

* http://docs.openstack.org/developer/ironic/drivers/vbox.html - Using Vbox to simulate baremetal nodes for ironic.  This assumes a base undertanding of how a lot of stuff works already.
* http://docs.openstack.org/developer/ironic/dev/dev-quickstart.html#deploying-ironic-with-devstack - Where I started.  Has a good walkthrough of EASILY setting it up and working with 3 kvm 'baremetal' hosts.
* http://docs.openstack.org/developer/ironic/deploy/install-guide.html - Had additional notes for creating baremetal nodes in ironic ... details missing in other guides above.
* https://www.rdoproject.org/Networking_in_too_much_detail - Crazy in depth info on how networking works in Openstack
* https://software.intel.com/en-us/articles/physical-server-provisioning-with-openstack - More misc references
