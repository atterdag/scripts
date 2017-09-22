#!/bin/sh
echo '***'
echo '*** copy certificates to docker configuration directory '
echo '***'
sudo cp /net/main/srv/common-setup/ssl/cacert.pem /etc/docker/certs/ca.crt
sudo cp /net/main/srv/common-setup/ssl/docker.example.com-cert.pem /etc/docker/certs/docker.crt
sudo cp /net/main/srv/common-setup/ssl/docker.example.com-key.pem /etc/docker/certs/docker.key

echo '***'
echo '*** creating docker daemon configuration '
echo '***'
cat > /etc/docker/daemon.json << EOF
{
    "iptables": true,
    "insecure-registries": ["registry.example.com:5000"],
    "tls": true,
    "tlsverify": true,
    "tlscacert": "/etc/docker/certs/ca.crt",
    "tlscert": "/etc/docker/certs/docker.crt",
    "tlskey": "/etc/docker/certs/docker.key",
    "debug": true
}
EOF

echo '***'
echo '*** restarting docker daemon'
echo '***'
/etc/init.d/docker restart
