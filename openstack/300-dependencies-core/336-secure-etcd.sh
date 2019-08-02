#!/bin/bash

##############################################################################
# Enable SSL for etcd on Controller host
##############################################################################

export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault login -method=userpass username=user password=$(cat ~/.VAULT_USER_PASS)

vault kv get --field=data keystores/${CONTROLLER_FQDN}.p12 \
| tr -d '\n' \
| base64 --decode \
> ${CONTROLLER_FQDN}.p12

openssl pkcs12 \
  -in ${CONTROLLER_FQDN}.p12 \
  -passin pass:${CONTROLLER_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| sudo tee /etc/ssl/certs/${CONTROLLER_FQDN}.crt

openssl pkcs12 \
  -in ${CONTROLLER_FQDN}.p12 \
  -passin pass:${CONTROLLER_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| sudo tee /etc/ssl/private/${CONTROLLER_FQDN}.key

# Ensure that the ssl-cert group owns the keypair
sudo chown root:ssl-cert \
  /etc/ssl/certs/${CONTROLLER_FQDN}.crt \
  /etc/ssl/private/${CONTROLLER_FQDN}.key

# Restrict access to the keypair
sudo chmod 644 /etc/ssl/certs/${CONTROLLER_FQDN}.crt
sudo chmod 640 /etc/ssl/private/${CONTROLLER_FQDN}.key

cat  <<EOF | sudo sed --file - --in-place /etc/default/etcd
s|^.*ETCD_NAME=.*|ETCD_NAME=\"${CONTROLLER_FQDN}\"|
s|^.*ETCD_DATA_DIR=.*|ETCD_DATA_DIR=\"/var/lib/etcd/default\"|
s|^.*ETCD_LISTEN_PEER_URLS=.*|ETCD_LISTEN_PEER_URLS=\"http://localhost:2380,http://${CONTROLLER_IP_ADDRESS}:2380,https://${CONTROLLER_IP_ADDRESS}:7001\"|
s|^.*ETCD_LISTEN_CLIENT_URLS=.*|ETCD_LISTEN_CLIENT_URLS=\"http://localhost:2379,http://${CONTROLLER_IP_ADDRESS}:2379,https://${CONTROLLER_IP_ADDRESS}:4001\"|
s|^.*ETCD_INITIAL_ADVERTISE_PEER_URLS=.*|ETCD_INITIAL_ADVERTISE_PEER_URLS=\"http://localhost:2380,http://${CONTROLLER_FQDN}:2380,https://${CONTROLLER_FQDN}:7001\"|
s|^.*ETCD_INITIAL_CLUSTER=.*|ETCD_INITIAL_CLUSTER=\"default=http://localhost:2380,default=http://${CONTROLLER_FQDN}:2380,default=https://${CONTROLLER_FQDN}:7001\"|
s|^.*ETCD_ADVERTISE_CLIENT_URLS=.*|ETCD_ADVERTISE_CLIENT_URLS=\"http://localhost:2379,http://${CONTROLLER_FQDN}:2379,https://${CONTROLLER_FQDN}:4001\"|
s|^.*ETCD_CERT_FILE=.*|ETCD_CERT_FILE=\"/etc/ssl/certs/${CONTROLLER_FQDN}.crt\"|
s|^.*ETCD_KEY_FILE=.*|ETCD_KEY_FILE=\"/etc/ssl/private/${CONTROLLER_FQDN}.key\"|
s|^.*ETCD_PEER_CERT_FILE.*|ETCD_PEER_CERT_FILE=\"/etc/ssl/certs/${CONTROLLER_FQDN}.crt\"|
s|^.*ETCD_PEER_KEY_FILE.*|ETCD_PEER_KEY_FILE=\"/etc/ssl/private/${CONTROLLER_FQDN}.key\"|
EOF

sudo usermod -a -G ssl-cert etcd

sudo systemctl restart etcd
