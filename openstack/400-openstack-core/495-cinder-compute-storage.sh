#!/bin/bash

##############################################################################
# Create premium (SDD) storage on Compute host
##############################################################################
# Example if you are reusing an existing disk
# sudo parted /dev/${LVM_PREMIUM_PV_DEVICE} mkpart primary $(sudo parted /dev/${LVM_PREMIUM_PV_DEVICE} unit s p free | grep "Free Space" | awk '{print $1}' | tail -n 1) 100%
# sudo parted --script /dev/${LVM_PREMIUM_PV_DEVICE} set 2 lvm on
# sudo pvcreate --yes /dev/${LVM_PREMIUM_PV_DEVICE}2
# sudo vgcreate cinder-volumes /dev/${LVM_PREMIUM_PV_DEVICE}2
# sudo vgcreate cinder-premium-vg /dev/${LVM_PREMIUM_PV_DEVICE}2

# Example if you have a dedicated disk
sudo parted --script /dev/${LVM_PREMIUM_PV_DEVICE} mklabel gpt
sudo parted --script /dev/${LVM_PREMIUM_PV_DEVICE} mkpart primary 0GB 100%
sudo parted --script /dev/${LVM_PREMIUM_PV_DEVICE} set 1 lvm on
sudo pvcreate --yes /dev/${LVM_PREMIUM_PV_DEVICE}1
sudo vgcreate cinder-premium-vg /dev/${LVM_PREMIUM_PV_DEVICE}1

##############################################################################
# Create standard (HDD) storage on Compute host
##############################################################################

sudo parted --script /dev/${LVM_STANDARD_PV_DEVICE} mklabel gpt
sudo parted --script /dev/${LVM_STANDARD_PV_DEVICE} mkpart primary 0GB 100%
sudo parted --script /dev/${LVM_STANDARD_PV_DEVICE} set 1 lvm on
sudo pvcreate --yes /dev/${LVM_STANDARD_PV_DEVICE}1
sudo vgcreate cinder-standard-vg /dev/${LVM_STANDARD_PV_DEVICE}1
