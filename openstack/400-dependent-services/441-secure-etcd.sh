#!/bin/sh

##############################################################################
# Enable SSL for etcd on Controller host
##############################################################################
sudo sed --file - --in-place /etc/default/etcd <<EOF
s|^.*ETCD_NAME=.*|ETCD_NAME=\"${CONTROLLER_FQDN}\"|
s|^.*ETCD_DATA_DIR=.*|ETCD_DATA_DIR=\"/var/lib/etcd/default\"|
s|^.*ETCD_LISTEN_PEER_URLS=.*|ETCD_LISTEN_PEER_URLS=\"http://localhost:2380,http://${CONTROLLER_IP_ADDRESS}:2380\"|
s|^.*ETCD_LISTEN_CLIENT_URLS=.*|ETCD_LISTEN_CLIENT_URLS=\"http://localhost:2379,http://${CONTROLLER_IP_ADDRESS}:2379\"|
s|^.*ETCD_INITIAL_ADVERTISE_PEER_URLS=.*|ETCD_INITIAL_ADVERTISE_PEER_URLS=\"http://localhost:2380,http://${CONTROLLER_FQDN}:2380\"|
s|^.*ETCD_INITIAL_CLUSTER=.*|ETCD_INITIAL_CLUSTER=\"default=http://localhost:2380,default=http://${CONTROLLER_FQDN}:2380\"|
s|^.*ETCD_ADVERTISE_CLIENT_URLS=.*|ETCD_ADVERTISE_CLIENT_URLS=\"http://localhost:2379,http://${CONTROLLER_FQDN}:2379\"|
s|^.*ETCD_CERT_FILE=.*|ETCD_CERT_FILE=\"/etc/ssl/certs/${CONTROLLER_FQDN}.crt\"|
s|^.*ETCD_KEY_FILE=.*|ETCD_KEY_FILE=\"/etc/ssl/private/${CONTROLLER_FQDN}.key\"|
s|^.*ETCD_PEER_CERT_FILE.*|ETCD_PEER_CERT_FILE=\"/etc/ssl/certs/${CONTROLLER_FQDN}.crt\"|
s|^.*ETCD_PEER_KEY_FILE.*|ETCD_PEER_KEY_FILE=\"/etc/ssl/private/${CONTROLLER_FQDN}.key\"|
EOF

sudo usermod -a -G ssl-cert etcd

sudo systemctl restart etcd
