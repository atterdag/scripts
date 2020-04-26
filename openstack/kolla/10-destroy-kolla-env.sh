#!/bin/sh

echo '***'
echo '*** delete kolla on Compute host'
echo '***'
kolla-ansible -i /etc/kolla/all-in-one destroy --include-images --yes-i-really-really-mean-it \
&& sudo rm -fr /etc/kolla

echo '***'
echo '*** delete premium (SDD) storage on Compute host'
echo '***'
sudo lvremove --force cinder-premium-vg/cinder-premium-vg-pool
sudo vgremove --force cinder-premium-vg
sudo pvremove --force /dev/${LVM_PREMIUM_PV_DEVICE}1
sudo parted --script /dev/${LVM_PREMIUM_PV_DEVICE} rm 1

echo '***'
echo '*** delete standard (HDD) storage on Compute host'
echo '***'
sudo lvremove --force cinder-standard-vg/cinder-standard-vg-pool
sudo vgremove --force cinder-standard-vg
sudo pvremove --force /dev/${LVM_STANDARD_PV_DEVICE}1
sudo parted --script /dev/${LVM_STANDARD_PV_DEVICE} rm 1

echo '***'
echo '*** delete standard (HDD) storage on Compute host'
echo '***'
sudo lvremove --force system/system-pool

echo '***'
echo '*** discard deleted space Compute host'
echo '***'
for mount_point in $(df -T|grep -E "ext4|btrfs"|awk '{print $7}'); do
  sudo fstrim -v $mount_point
done
