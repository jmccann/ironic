#!/bin/bash

VM='baremetal'

VBoxManage createhd --filename ~/VirtualBox\ VMs/$VM.vdi --size 12768
VBoxManage createvm --name $VM --register
VBoxManage storagectl $VM --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach $VM --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ~/VirtualBox\ VMs/$VM.vdi

VBoxManage modifyvm $VM --ioapic on
VBoxManage modifyvm $VM --boot1 net --boot2 disk --boot3 none --boot4 none
VBoxManage modifyvm $VM --memory 4096 --vram 128
VBoxManage modifyvm $VM --nic1 intnet --nictype1 82540EM --macaddress1 0800276EDF70
