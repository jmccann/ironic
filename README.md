Ironic
======

Using Stackforge to deploy a standalone Ironic environment.

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

Credentials for services are stored using databags.  We are using chef-vault.
For Dev/CI we are using 'simulated' chef-vaults.

## Databag Items Required

See dev databags @ [test/integration/data_bags](test/integration/data_bags)

* vault_db_passwords
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
* vault_secrets
  * neutron_metadata_secret
  * openstack_identity_bootstrap_token
  * swift_authkey
  * swift_hash_path_prefix
  * swift_hash_path_suffix
* vault_serivce_passwords
  * admin - should match value in vault_user_passwords:admin
  * openstack-bare-metal
  * openstack-block-storage
  * openstack-compute
  * openstack-image
  * openstack-network
  * openstack-object-storage
* vault_user_passwords
  * admin
  * guest
  * mysqlroot

# Dashboard

When it is done you can hit the dashboard @ http://localhost:8080/ admin:password

# Install VirtualBox PXE Driver
Install VirtualBox Extension Pack for PXE Driver support from https://www.virtualbox.org/wiki/Downloads

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
bundle exec kitchen conv
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
NODE_UUID=$(ironic node-list | egrep "my-baremetal"'[^-]' | awk '{ print $2 }')
image=$(nova image-list | egrep "cirros"'[^-]' | awk '{ print $2 }')
net_id=$(neutron net-list | egrep "baremetal"'[^-]' | awk '{ print $2 }')

ironic node-update $NODE_UUID add instance_info/image_source=$image
ironic node-update $NODE_UUID add instance_info/root_gb=11

nova boot --flavor my-baremetal-flavor --nic net-id=$net_id --image $image --key-name default testing

watch ironic node-list
```

Can take up to 5 min before VM will auto power-on.  Be patient.

# Inspector

Currently inspector is configured to run.  It may cause issues with demo'ing as it runs it's own DHCP server alongside neutrons and we have it running on the same network.  This is because neutron does not currently serve addresses to 'unknown' systems which is required for discovery.  Work continues to finalize a solution by having discovery DHCP not serve addresses to systems we DO know about.

Inspector works by providing a 'default' DHCP/PXE for systems.  They then boot a discovery ramdisk that gathers system information and POSTs it back to the inspector API.

To use inspector you use:
* Register the system in Ironic with:
 * BMC information
* Set the system in a manage state
 * `ironic node-set-provision-state $NODE manage`
* Inspect the system
 * `ironic node-set-provision-state $NODE inspect`
* Put the system back in the pool after inspection is done
 * `ironic node-set-provision-state $NODE provide`

Currently BMC Address, MACs, CPU, Disk and Memory are gathered.

Mapping of discovered node to ironic metadata is done by matching:
* BMC IP discovered to node registered in Ironic with same BMC address
* MACs discovered to node registered in Ironic with same MAC (ironic port)

You can extend inspection by:
* Adding 'plugins' to the inspector API.  This is basically creating new API endpoints and mapping how to update the node in ironic.
* Generating a discovery ramdisk with logic on how to collect the additional information and how to post it to the inspector API
 * Could create additional discovery elements to manage building an extended discovery ramdisk with diskimage-builder

By default you can only use inspector with pxe_ drivers.  However we have PoC'd adding code to agent_ drivers with agent_vbox and it seems to be working fine.  We will extend the rest of the agent_ drivers as well in the future.

# Control node selection

Driven by setting `capabilities` in ironic node and nova flavor.

* Example at: http://docs.openstack.org/developer/ironic/deploy/install-guide.html#boot-mode-support
* Implemented in: https://blueprints.launchpad.net/nova/+spec/pass-flavor-capabilities-to-ironic-virt-driver

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
