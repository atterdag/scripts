#!/bin/bash

##############################################################################
# Install Etcd on Controller host
##############################################################################
sudo add-apt-repository universe
sudo apt-get --yes --quiet install \
  etcd

cat  <<EOF | sudo sed --file - --in-place /etc/default/etcd
s|^.*ETCD_NAME=.*|ETCD_NAME=\"${CONTROLLER_FQDN}\"|
s|^.*ETCD_DATA_DIR=.*|ETCD_DATA_DIR=\"/var/lib/etcd/default\"|
s|^.*ETCD_LISTEN_PEER_URLS=.*|ETCD_LISTEN_PEER_URLS=\"http://localhost:2380,http://${CONTROLLER_IP_ADDRESS}:2380\"|
s|^.*ETCD_LISTEN_CLIENT_URLS=.*|ETCD_LISTEN_CLIENT_URLS=\"http://localhost:2379,http://${CONTROLLER_IP_ADDRESS}:2379\"|
s|^.*ETCD_INITIAL_ADVERTISE_PEER_URLS=.*|ETCD_INITIAL_ADVERTISE_PEER_URLS=\"http://localhost:2380,http://${CONTROLLER_FQDN}:2380\"|
s|^.*ETCD_INITIAL_CLUSTER=.*|ETCD_INITIAL_CLUSTER=\"default=http://localhost:2380,default=http://${CONTROLLER_FQDN}:2380\"|
s|^.*ETCD_ADVERTISE_CLIENT_URLS=.*|ETCD_ADVERTISE_CLIENT_URLS=\"http://localhost:2379,http://${CONTROLLER_FQDN}:2379\"|
EOF

sudo systemctl enable etcd
sudo systemctl start etcd
