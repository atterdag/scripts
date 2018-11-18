#!/bin/sh

echo '***'
echo '*** add docker to UFW'
echo '***'
cat << EOF | sudo tee /etc/ufw/applications.d/docker
[dockerd]
title=Docker daemon
description=Docker daemon TLS listening port.
ports=2376/tcp
EOF
sudo ufw allow dockerd
