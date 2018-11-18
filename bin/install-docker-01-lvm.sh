#!/bin/sh

echo '***'
echo '*** setting up disk'
echo '***'
sudo pvcreate /dev/sdb
sudo vgcreate containers /dev/sdb
yes | sudo lvcreate --size 5G --name docker containers
# I prefer butterfs, but Kubernetes doesn't support it
#mkfs.btrfs /dev/containers/docker
sudo mkfs.xfs -f /dev/containers/docker
echo -e "/dev/mapper/containers-docker /var/lib/docker xfs defaults\t0\t0" | sudo tee -a /etc/fstab
sudo mkdir /var/lib/docker
sudo mount /var/lib/docker
