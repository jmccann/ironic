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
