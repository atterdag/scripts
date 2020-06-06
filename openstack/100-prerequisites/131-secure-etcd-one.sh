d#!/bin/bash

##############################################################################
# Enable SSL for etcd on MANAGEMENT host
##############################################################################

export ETCDCTL_ENDPOINTS="http://localhost:2379"

# Get read privileges to etcd
if [[ -z ${ETCD_USER_PASS+x} ]]; then echo "Fetch from user password from secret management"; read ETCD_USER_PASS; fi

# Retrieve MANAGEMENT keystore from etcd
etcdctl --username user:$ETCD_USER_PASS get /keystores/${ETCD_ONE_FQDN}.p12 \
| tr -d '\n' \
| base64 --decode \
> ${ETCD_ONE_FQDN}.p12

openssl pkcs12 \
  -in ${ETCD_ONE_FQDN}.p12 \
  -passin pass:${MANAGEMENT_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| sudo tee /etc/ssl/certs/${ETCD_ONE_FQDN}.crt

openssl pkcs12 \
  -in ${ETCD_ONE_FQDN}.p12 \
  -passin pass:${MANAGEMENT_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| sudo tee /etc/ssl/private/${ETCD_ONE_FQDN}.key

# Ensure that the ssl-cert group owns the keypair
sudo chown root:ssl-cert \
  /etc/ssl/certs/${ETCD_ONE_FQDN}.crt \
  /etc/ssl/private/${ETCD_ONE_FQDN}.key

# Restrict access to the keypair
sudo chmod 644 /etc/ssl/certs/${ETCD_ONE_FQDN}.crt
sudo chmod 640 /etc/ssl/private/${ETCD_ONE_FQDN}.key

cat  <<EOF | sudo sed --file - --in-place /etc/default/etcd
s|^.*ETCD_INITIAL_ADVERTISE_PEER_URLS=.*|ETCD_INITIAL_ADVERTISE_PEER_URLS=\"https://${ETCD_ONE_FQDN}:2380\"|
s|^.*ETCD_LISTEN_PEER_URLS=.*|ETCD_LISTEN_PEER_URLS=\"https://${ETCD_ONE_IP_ADDRESS}:2380\"|
s|^.*ETCD_LISTEN_CLIENT_URLS=.*|ETCD_LISTEN_CLIENT_URLS=\"https://${ETCD_ONE_IP_ADDRESS}:2379,http://127.0.0.1:2379\"|
s|^.*ETCD_ADVERTISE_CLIENT_URLS=.*|ETCD_ADVERTISE_CLIENT_URLS=\"https://${ETCD_ONE_FQDN}:2379\"|
s|^.*ETCD_INITIAL_CLUSTER=.*|ETCD_INITIAL_CLUSTER=\"${ETCD_ONE_HOST_NAME}=https://${ETCD_ONE_FQDN}:2380,${ETCD_TWO_HOST_NAME}=https://${ETCD_TWO_IP_ADDRESS}:2380\"|
s|^.*ETCD_CERT_FILE.*|ETCD_CERT_FILE=\"/etc/ssl/certs/${ETCD_ONE_FQDN}.crt\"|
s|^.*ETCD_KEY_FILE.*|ETCD_KEY_FILE=\"/etc/ssl/private/${ETCD_ONE_FQDN}.key\"|
s|^.*ETCD_PEER_CERT_FILE.*|ETCD_PEER_CERT_FILE=\"/etc/ssl/certs/${ETCD_ONE_FQDN}.crt\"|
s|^.*ETCD_PEER_KEY_FILE.*|ETCD_PEER_KEY_FILE=\"/etc/ssl/private/${ETCD_ONE_FQDN}.key\"|
EOF

sudo usermod -a -G ssl-cert etcd

sudo systemctl restart etcd
