#!/bin/sh

echo '***'
echo '*** setting up disk'
echo '***'
sudo parted /dev/vdb mklabel gpt
sudo parted /dev/vdb mkpart primary 0GB 100%
sudo parted -s /dev/vdb set 1 lvm on
sudo pvcreate /dev/vdb1
sudo vgcreate containers /dev/vdb1
yes | sudo lvcreate --size 5G --name docker containers
sudo mkfs.xfs -f /dev/containers/docker
echo -e "/dev/mapper/containers-docker /var/lib/docker xfs defaults,nofail\t0\t0" | sudo tee -a /etc/fstab
sudo mkdir /var/lib/docker
sudo mount /var/lib/docker
