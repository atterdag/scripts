#!/bin/sh

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
