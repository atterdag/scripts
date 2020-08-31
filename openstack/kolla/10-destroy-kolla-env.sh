#!/bin/sh

echo '***'
echo '*** enable virtualenv'
echo '***'
if [[ -z ${WORKON_ON+x} ]]; then workon kolla; fi

echo '***'
echo '*** destroy kolla on Compute host'
echo '***'
kolla-ansible \
  --inventory /etc/kolla/all-in-one destroy \
  --include-images \
  --yes-i-really-really-mean-it

echo '***'
echo '*** delete kolla configuration on Compute host'
echo '***'
sudo rm \
  --force \
  --recursive \
  /etc/kolla

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

echo '***'
echo '*** delete kolla user'
echo '***'
sudo userdel -r kolla

echo '***'
echo '*** remove docker packages'
echo '***'
sudo /etc/init.d/docker stop
sudo apt-get --yes --quiet --reinstall remove \
  docker-ce
sudo apt-get --yes --quiet --purge autoremove
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo apt-key del 0EBFCD88

echo '***'
echo '*** removing docker space'
echo '***'
sudo umount /var/lib/docker
sudo sed -i '/system-docker/,$d' /etc/fstab
sudo rmdir /var/lib/docker
sudo lvremove --yes system/docker
