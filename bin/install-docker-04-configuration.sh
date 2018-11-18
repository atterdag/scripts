#!/bin/sh

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
sudo /etc/init.d/docker restart
