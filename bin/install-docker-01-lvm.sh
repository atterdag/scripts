#!/bin/sh

echo '***'
echo '*** setting up disk'
echo '***'
sudo parted /dev/sda mklabel gpt
sudo parted /dev/sda mkpart primary 0GB 100%
sudo parted -s /dev/sda set 1 lvm on
sudo pvcreate /dev/sda1
sudo vgcreate containers /dev/sda1
yes | sudo lvcreate --size 5G --name docker containers
sudo mkfs.btrfs /dev/containers/docker
echo -e "/dev/mapper/containers-docker /var/lib/docker btrfs defaults\t0\t0" | sudo tee -a /etc/fstab
sudo mkdir /var/lib/docker
sudo mount /var/lib/docker
