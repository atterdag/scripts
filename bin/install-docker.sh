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

echo '***'
echo '*** setup environment'
echo '***'
HOSTNAME=$(hostname -s)

echo '***'
echo '*** adding forwarding proxy configuration to shell'
echo '***'
cat << EOF | sudo tee /etc/profile.d/proxyenv.sh
proxy_host="cache.example.com"
proxy_port="3128"

http_proxy="http://\${proxy_host}:\${proxy_port}";
https_proxy="https://\${proxy_host}:\${proxy_port}";
ftp_proxy="ftp://\${proxy_host}:\${proxy_port}";
no_proxy=localhost,127.0.0.1,LocalAddress,example.com,example.lan

export http_proxy https_proxy ftp_proxy no_proxy;
EOF
. /etc/profile.d/proxyenv.sh

echo '***'
echo '*** updating APT repositories'
echo '***'
sudo apt-get update
sudo apt-get -y install \
                apt-transport-https \
                ca-certificates \
                gnupg2 \
                software-properties-common \
                wget

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
# deb-src [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable
EOF

echo '***'
echo '*** updating APT repositories'
echo '***'
sudo apt-get update

echo '***'
echo '*** installing docker-ce'
echo '***'
#sudo apt-get -y install docker-ce # Kubernetes doesn't support futher than docker-ce 17.03
sudo apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

echo '***'
echo '*** adding forwarding proxy configuration to docker daemon'
echo '***'
if [ ! -d /etc/systemd/system/docker.service.d ]; then sudo mkdir -p /etc/systemd/system/docker.service.d; fi
cat << EOF | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${http_proxy}"
Environment="HTTPS_PROXY=${https_proxy}"
Environment="FTP_PROXY=${ftp_proxy}"
Environment="NO_PROXY=${no_proxy}"
EOF
sudo systemctl daemon-reload
systemctl show --property=Environment docker

echo '***'
echo '*** allow TCP connection'
echo '***'
if [ ! -d /etc/systemd/system/docker.service.d ]; then sudo mkdir -p /etc/systemd/system/docker.service.d; fi
cat << EOF | sudo tee /etc/systemd/system/docker.service.d/override.conf
[Service]
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376
EOF
sudo systemctl daemon-reload
systemctl show --property=ExecStart docker

echo '***'
echo '*** copy certificates to docker configuration directory'
echo '***'
sudo cp /net/main/srv/common-setup/ssl/cacert.pem /etc/ssl/cacert.pem
sudo cp /net/main/srv/common-setup/ssl/${HOSTNAME}.example.com-cert.pem /etc/ssl/${HOSTNAME}.example.com-cert.pem
sudo cp /net/main/srv/common-setup/ssl/${HOSTNAME}.example.com-key.pem /etc/ssl/private/${HOSTNAME}.example.com-key.pem

echo '***'
echo '*** creating docker daemon configuration'
echo '***'
cat << EOF | sudo tee /etc/docker/daemon.json
{
    "iptables": true,
    "insecure-registries": ["registry.example.com:5000"],
    "tls": true,
    "tlsverify": true,
    "tlscacert": "/etc/ssl/certs/ca-certificates.crt",
    "tlscert": "/etc/ssl/${HOSTNAME}.example.com-cert.pem",
    "tlskey": "/etc/ssl/private/${HOSTNAME}.example.com-key.pem",
    "debug": false
}
EOF

echo '***'
echo '*** restarting docker daemon'
echo '***'
cat << EOF | sudo tee /etc/ufw/applications.d/docker
[dockerd]
title=Docker daemon
description=Docker daemon TLS listening port.
ports=2376/tcp
EOF
sudo ufw allow dockerd

echo '***'
echo '*** restarting docker daemon'
echo '***'
sudo /etc/init.d/docker restart
