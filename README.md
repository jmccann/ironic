Ironic
======

# Attributes
* `default['ironic']['agent']` (default: 'pxe_vbox') - What ironic agent to use.
Valid values include: `pxe_vbox` and `agent_vbox`
 * **Note**: agent_vbox will build a system but if set to net boot first will
 hang on deploy image after reboot.  THIS IS EXPECTED!  See note @ http://docs.openstack.org/developer/ironic/_modules/ironic/drivers/modules/virtualbox.html
 * There are some PXE issues with agent_vbox that are still being worked through.  Currently you will need to follow instructions to stack and finalize.  It will probably not work.  You then need to unstack, stack again, finalize again and it should work.

# Setup the stack

## pxe_vbox
```
bundle exec kitchen conv
bundle exec kitchen login
sudo su - stack
```

Now wait about 30 min.

You can login to the instance on another terminal window and watch it build:
```
bundle exec kitchen login
sudo su - stack
tail -f /opt/stack/devstack.log
```


## agent_vbox
```
bundle exec kitchen conv
bundle exec kitchen login
sudo su - stack
cd devstack/stack.sh
./finalize.sh
```

# Dashboard

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

# Verify stuff

```
source ~/devstack/openrc admin admin
NODE_UUID=$(ironic node-list | egrep "my-baremetal"'[^-]' | awk '{ print $2 }')
ironic node-show $NODE_UUID
ironic node-validate $NODE_UUID
```

# Boot an instance to the node
Using pxe_vbox:
```
source ~/devstack/openrc admin admin
nova keypair-add default --pub-key ~/.ssh/id_rsa.pub
NODE_UUID=$(ironic node-list | egrep "my-baremetal"'[^-]' | awk '{ print $2 }')
image=$(nova image-list | egrep "cirros-.*-uec "'[^-]' | awk '{ print $2 }')

ironic node-update $NODE_UUID add instance_info/root_gb=11
ironic node-update $NODE_UUID add instance_info/image_source=$image

net_id=$(neutron net-list | egrep "sharednet1"'[^-]' | awk '{ print $2 }')
nova boot --flavor my-baremetal-flavor --nic net-id=$net_id --image $image --key-name default testing
ironic node-list
```

Using agent_vbox
```
source ~/devstack/openrc admin admin
nova keypair-add default --pub-key ~/.ssh/id_rsa.pub
NODE_UUID=$(ironic node-list | egrep "my-baremetal"'[^-]' | awk '{ print $2 }')
image=$(nova image-list | egrep "cirros-.*-x86_64-disk"'[^-]' | awk '{ print $2 }')

ironic node-update $NODE_UUID add instance_info/root_gb=11
ironic node-update $NODE_UUID add instance_info/image_source=$image

net_id=$(neutron net-list | egrep "sharednet1"'[^-]' | awk '{ print $2 }')
nova boot --flavor my-baremetal-flavor --nic net-id=$net_id --image $image --key-name default testing
ironic node-list
```

Can take up to like 10 sec before VM will auto power-on.  Be patient.

# Resources

* http://docs.openstack.org/developer/ironic/drivers/vbox.html - Using Vbox to simulate baremetal nodes for ironic.  This assumes a base undertanding of how a lot of stuff works already.
* http://docs.openstack.org/developer/ironic/dev/dev-quickstart.html#deploying-ironic-with-devstack - Where I started.  Has a good walkthrough of EASILY setting it up and working with 3 kvm 'baremetal' hosts.
* http://docs.openstack.org/developer/ironic/deploy/install-guide.html - Had additional notes for creating baremetal nodes in ironic ... details missing in other guides above.
* https://www.rdoproject.org/Networking_in_too_much_detail - Crazy in depth info on how networking works in Openstack
* https://software.intel.com/en-us/articles/physical-server-provisioning-with-openstack - More misc references
* https://github.com/openstack/ironic/blob/master/doc/source/drivers/ilo.rst - Had useful references for agent based deploy ... like generating deploy image and configuring ironic to use swift
