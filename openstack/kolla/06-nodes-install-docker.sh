#!/bin/sh

cat <<EOF | ssh ${DEPLOY_USER_NAME}@${COMPUTE_FQDN}
echo '***'
echo '*** setting up docker space'
echo '***'
sudo lvcreate --yes --size 20G --name docker system
sudo mkfs.btrfs /dev/system/docker
echo -e "/dev/mapper/system-docker /var/lib/docker btrfs defaults\t0\t0" | sudo tee -a /etc/fstab
sudo mkdir /var/lib/docker
sudo mount /var/lib/docker

echo '***'
echo '*** adding docker repository GPG key'
echo '***'
wget -q -O - https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -

echo '***'
echo '*** check that GPG key have been registered'
echo '***'
sudo apt-key fingerprint 0EBFCD88

echo '***'
echo '*** adding docker APT repository'
echo '***'
cat << EOF | sudo tee /etc/apt/sources.list.d/docker.list
deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable
deb-src [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable

echo '***'
echo '*** updating APT repositories'
echo '***'
sudo apt-get update

echo '***'
echo '*** installing docker-ce'
echo '***'
sudo apt-get --yes --quiet --reinstall install docker-ce

echo '***'
echo '*** restarting docker daemon'
echo '***'
sudo /etc/init.d/docker restart

echo '***'
echo '*** test docker'
echo '***'
sudo -g docker docker run hello-world

echo '***'
echo '*** add user to docker group'
echo '***'
sudo usermod -a -G docker $USER
EOF
