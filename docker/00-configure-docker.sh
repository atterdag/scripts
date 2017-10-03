#!/bin/sh

export http_proxy=http://cache.example.com:3128/
export https_proxy=https://cache.example.com:3128/
export ftp_proxy=ftp://cache.example.com:3128/
export no_proxy=localhost,127.0.0.1,LocalAddress,example.com,example.lan
HOSTNAME=$(hostname -s)

echo '***'
echo '*** removing any past versions of docker'
echo '***'
sudo apt-get --yes remove docker docker-engine docker.io docker-ce
sudo apt-get --yes --purge autoremove
sudo rm -fr /etc/docker \
            /var/lib/docker/*

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
#sudo apt-get -y install docker-ce
sudo apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

echo '***'
echo '*** adding forwarding proxy configuration'
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

echo '***'
echo '*** copy certificates to docker configuration directory'
echo '***'
if [ ! -d /etc/docker/certs ]; then sudo mkdir -p /etc/docker/certs/; fi
sudo cp /net/main/srv/common-setup/ssl/cacert.pem /etc/ssl/cacert.pem
sudo cp /net/main/srv/common-setup/ssl/${HOSTNAME}.example.com-cert.pem /etc/ssl/${HOSTNAME}.example.com-cert.pem
sudo cp /net/main/srv/common-setup/ssl/${HOSTNAME}.example.com-key.pem /etc/ssl/private/${HOSTNAME}.example.com-key.pem

echo '***'
echo '*** creating docker daemon configuration '
echo '***'
cat << EOF | sudo tee /etc/docker/daemon.json
{
    "iptables": true,
    "insecure-registries": ["registry.example.com:5000"],
    "tls": true,
    "tlsverify": true,
    "tlscacert": "/etc/ssl/cacert.pem",
    "tlscert": "/etc/ssl/${HOSTNAME}.example.com-cert.pem",
    "tlskey": "/etc/ssl/private/${HOSTNAME}.example.com-key.pem",
    "debug": false
}
EOF

echo '***'
echo '*** restarting docker daemon'
echo '***'
sudo /etc/init.d/docker restart

echo '***'
echo '*** Add your user to the docker group to run docker'
echo '***'
sudo usermod -aG docker $USER

echo '***'
echo '*** checking that docker works'
echo '***'
sudo -g docker docker run hello-world
