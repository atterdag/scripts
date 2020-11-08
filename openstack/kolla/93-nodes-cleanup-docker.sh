#!/bin/sh

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
