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
deb [arch=arm64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable
# deb-src [arch=arm64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable
EOF

echo '***'
echo '*** updating APT repositories'
echo '***'
sudo apt-get update

echo '***'
echo '*** installing docker'
echo '***'
sudo apt install --yes docker-ce docker-ce-cli containerd.io

echo '***'
echo '*** enable systemd cgroup driver docker'
echo '***'
if [ ! -d /etc/systemd/system/docker.service.d ]; then sudo mkdir -p /etc/systemd/system/docker.service.d; fi
sudo systemctl daemon-reload

echo '***'
echo '*** creating docker daemon configuration'
echo '***'
cat << EOF | sudo tee /etc/docker/daemon.json
{
  "tlscacert": "/etc/ssl/certs/ca-certificates.crt",
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

echo '***'
echo '*** restarting docker daemon'
echo '***'
sudo /etc/init.d/docker restart

echo '***'
echo '*** add user to docker group'
echo '***'
sudo usermod --append --groups docker $USER

echo '***'
echo '*** test docker'
echo '***'
sudo sg docker -c "docker container run --rm hello-world"
