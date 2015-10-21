4.3.0
-----
* Ability to manage processing_hooks in discoverd.conf file
* Ability to manage discovery ramdisk after creation if checksums are provided

4.2.1
-----
* bug: Was trying to load chef-vault before it was installed

4.2.0
-----
* Allow setting Ironic deploy timeout callback
* bug: Pin to chef-vault 1.3.0 cookbook ... major changes with minor version bump sucks

4.1.1
-----
* Speed up neutron network population

4.1.0
-----
* Disable node cleaning when no cleaning network is specified

4.0.2
-----
* revert: Create network using flat network name instead of bridge interface name (this was not a bug and instead introduced one)
* bug: Change how to restart neutron services

4.0.1
-----
* bug: mkdir path to ironic log directory
* bug: Restart neutron services on config change so new flat networks are available to populate against
* bug: Create network using flat network name instead of bridge interface name

4.0.0
-----
* Allow defining multiple subnets in a network

3.1.5
-----
* Change default value for attr `networks` from `[]` to `{}` to better reflect the datastructure

3.1.4
-----
* Change default value for attr `bridges` from `[]` to `{}` to better reflect the datastructure

3.1.3
-----
* Pin chef-vault dependency to current latest

3.1.2
-----
* Another bugfix for chef-vault

3.1.1
-----
* Fix chef-vault access

3.1.0
-----
* Add 'inspect' to agent_ipmitool driver

3.0.2
-----
* TFTP testing

3.0.1
-----
* Fix tftpboot/pxelinux.cfg perms issue for Ironic

3.0.0
-----
* Have inspector use tftp server provided for ironic

2.5.0
-----
* Only download discovery ramdisk if missing

2.4.0
-----
* Add metadata service

2.3.0
-----
* Add ironic inspector

2.2.1
-----
* Fix ironic conductor to clean nodes properly

2.2.0
-----
* Ability to set gateway on defined neutron subnet

2.1.0
-----
* Ability to set default gw when assigning primary IP to a bridge interface

2.0.3
-----
* Fix bug in setting invalid enabled_drivers for Ironic

2.0.2
-----
* Install ipmitool package

2.0.1
-----
* Fix OVS bridge mapping config bug

2.0.0
-----
* Allow defining multiple networks per managed interface
 * Includes reworking of some attributes

1.1.3
-----
* Fix guards for glance image upload

1.1.2
-----
* Add ENV to guards to support Chef 11

1.1.1
-----
* Add guard to removing IP from phys int

1.1.0
-----
* Ability to use physical address on bridge interface

1.0.3
-----
* Remove requirement for tempurl key in node attribute
* Randomize passwords
* Use chef-vault for dev/CI

1.0.2
-----
* Move some values from kitchen as default cookbook values
* Update doc on required databag items for creds
* Rename recipe for populating images into glance
* Remove unused dev databags
* Update default attribute on how creds would be stored
