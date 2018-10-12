#!/bin/sh

echo '***'
echo '*** checking that the daemon is listening on TCP using SSL'
echo '***'
echo | openssl s_client -connect docker.example.com:2376

echo '***'
echo '*** Add your local user to the docker group to run docker'
echo '***'
sudo usermod -aG docker $USER

echo '***'
echo '*** Configure a workstation to connect to your docker host'
echo '***'
if [ ! -d /etc/docker/certs ]; then sudo mkdir -p /etc/docker/certs; fi
sudo cp /net/main/srv/common-setup/ssl/cacert.pem /etc/docker/certs/ca.pem
cat << EOF | sudo tee /etc/profile.d/docker.sh
DOCKER_CERT_PATH=/etc/docker/certs
DOCKER_HOST=tcp://docker.example.com:2376
DOCKER_TLS_VERIFY=1
export DOCKER_TLS_VERIFY DOCKER_HOST DOCKER_CERT_PATH
EOF

echo '***'
echo '*** checking that docker works'
echo '***'
sudo -g docker docker run hello-world

echo '***'
echo '*** logout from user, and login again'
echo '***'
logout
