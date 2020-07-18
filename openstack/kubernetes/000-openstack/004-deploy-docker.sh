#!/bin/bash

sudo hostnamectl set-hostname master01.k8s.se.lemche.net
sudo hostnamectl set-hostname worker01.k8s.se.lemche.net
sudo hostnamectl set-hostname worker02.k8s.se.lemche.net

# Install Docker CE
## Set up the repository
### Install required packages.
sudo yum install -y \
  yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo parted /dev/vdb mklabel gpt
sudo parted /dev/vdb mkpart primary 0GB 100%
sudo parted -s /dev/vdb set 1 lvm on
sudo pvcreate /dev/vdb1
sudo vgcreate dockervg /dev/vdb1

echo '***'
echo '*** setting up docker space'
echo '***'
yes | sudo lvcreate --size 10G --name docker dockervg
sudo mkfs.xfs /dev/dockervg/docker
echo -e "/dev/mapper/dockervg-docker /var/lib/docker xfs defaults\t0\t0" | sudo tee -a /etc/fstab
sudo mkdir /var/lib/docker
sudo mount /var/lib/docker

### Add Docker repository.
sudo yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

## Install Docker CE.
sudo yum -y update \
&& sudo yum install -y docker-ce-18.06.2.ce

## Create /etc/docker directory.
sudo mkdir /etc/docker

# Configure the Docker daemon
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

echo '***'
echo '*** add user to docker group'
echo '***'
sudo usermod -a -G docker $USER

echo '***'
echo '*** test docker'
echo '***'
sg docker -c "docker run hello-world"

sudo reboot
