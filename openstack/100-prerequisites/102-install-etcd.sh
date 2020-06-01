#!/bin/bash

##############################################################################
# Install Etcd on Controller host
##############################################################################
sudo add-apt-repository --enable-source --yes --update universe

if [[ $(uname --machine) == aarch64 ]]; then
  cat <<EOF | sudo tee /usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF
  sudo chmod +x /usr/sbin/policy-rc.d
fi

sudo apt-get --yes --quiet install \
  etcd

if [[ $(uname --machine) == aarch64 ]]; then
  if [[ -f /usr/sbin/policy-rc.d ]]; then
    sudo rm -f /usr/sbin/policy-rc.d
  fi
  echo 'ETCD_UNSUPPORTED_ARCH=arm64' | sudo tee -a /etc/default/etcd
fi

sudo systemctl enable etcd
sudo systemctl start etcd

cat <<EOF | sudo tee /etc/ufw/applications.d/etcd
[etcd]
title=etcd
description=A distributed, reliable key-value store for the most critical data of a distributed system.
ports=2379,2380/tcp
EOF

sudo ufw allow etcd
