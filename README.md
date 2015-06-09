Ironic
======

Using Stackforge to deploy an Ironic environment.

# Attributes

* `['ironic']['interfaces']` (default: []) - Array of interface to bridge mappings for each network to build on.
* `['openstack']['databag_type']` (default: 'vault') - Set databag type acceptable values
  'encrypted', 'standard', 'vault' Set this to 'standard' in order to use regular databags.
  this is not recommended for anything other than dev/CI
  type environments.  Storing real secrets in plaintext = craycray.
  In addition to the encrypted data_bags which are an included
  feature of the official chef project, you can use 'vault' to
  encrypt your secrets with the method provided in the chef-vault gem.

# Credentials

Credentials for services are stored using databags.  For Dev/CI we are using plaintext databags.
For prod we use chef-vault.

## Databag Items Required

See dev databags @ [test/integration/data_bags](test/integration/data_bags)

* db_passwords
  * ceilometer
  * cinder
  * dash
  * glance
  * heat
  * horizon
  * ironic
  * keystone
  * neutron
  * nova
* secrets
  * neutron_metadata_secret
  * openstack_identity_bootstrap_token
  * swift_authkey
  * swift_hash_path_prefix
  * swift_hash_path_suffix
* serivce_passwords
  * admin
  * openstack-bare-metal
  * openstack-block-storage
  * openstack-compute
  * openstack-image
  * openstack-network
  * openstack-object-storage
* user_passwords
  * admin
  * guest
  * mysqlroot

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

# Run Chef
```
bexec kitchen conv
```

# Verify stuff

```
bexec kitchen login
sudo su -
. ~/openrc
NODE_UUID=$(ironic node-list | egrep "my-baremetal"'[^-]' | awk '{ print $2 }')
ironic node-show $NODE_UUID
ironic node-validate $NODE_UUID
```

# Boot an instance to the node

```
bexec kitchen login
sudo su -
. ~/openrc
source ~/devstack/openrc admin admin
NODE_UUID=$(ironic node-list | egrep "my-baremetal"'[^-]' | awk '{ print $2 }')
image=$(nova image-list | egrep "cirros"'[^-]' | awk '{ print $2 }')

ironic node-update $NODE_UUID add instance_info/image_source=$image
ironic node-update $NODE_UUID add instance_info/root_gb=11

NODE_UUID=$(ironic node-list | egrep "my-baremetal"'[^-]' | awk '{ print $2 }')
image=$(nova image-list | egrep "cirros"'[^-]' | awk '{ print $2 }')
net_id=$(neutron net-list | egrep "baremetal"'[^-]' | awk '{ print $2 }')

nova boot --flavor my-baremetal-flavor --nic net-id=$net_id --image $image --key-name default testing

watch ironic node-list
```

Can take up to 5 min before VM will auto power-on.  Be patient.

# Resources

* http://docs.openstack.org/developer/ironic/drivers/vbox.html - Using Vbox to simulate baremetal nodes for ironic.  This assumes a base undertanding of how a lot of stuff works already.
* http://docs.openstack.org/developer/ironic/dev/dev-quickstart.html#deploying-ironic-with-devstack - Where I started.  Has a good walkthrough of EASILY setting it up and working with 3 kvm 'baremetal' hosts.
* http://docs.openstack.org/developer/ironic/deploy/install-guide.html - Had additional notes for creating baremetal nodes in ironic ... details missing in other guides above.
* https://www.rdoproject.org/Networking_in_too_much_detail - Crazy in depth info on how networking works in Openstack
* https://software.intel.com/en-us/articles/physical-server-provisioning-with-openstack - More misc references
* https://github.com/openstack/ironic/blob/master/doc/source/drivers/ilo.rst - Had useful references for agent based deploy ... like generating deploy image and configuring ironic to use swift
* http://docs.openstack.org/image-guide/content/ch_modifying_images.html - How to edit images
* https://developer.rackspace.com/blog/how-we-run-ironic-and-you-can-too/ - Great writeup on how rackspace is using ironic
* https://github.com/rackerlabs/ironic-neutron-plugin - ironic/neutron plugin for managing cisco nexus hardware???
