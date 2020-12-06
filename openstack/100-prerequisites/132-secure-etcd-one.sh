d#!/bin/bash

##############################################################################
# Enable SSL for etcd on MANAGEMENT host
##############################################################################

export ETCDCTL_ENDPOINTS="http://localhost:2379"

# Get read privileges to etcd
if [[ -z ${ETCD_USER_PASS+x} ]]; then echo "Fetch from user password from secret management"; read -s ETCD_USER_PASS; fi

# Retrieve MANAGEMENT keystore from etcd
etcdctl --username user:$ETCD_USER_PASS get /keystores/ETCD_ONE.p12 \
| tr -d '\n' \
| base64 --decode \
> ${ETCD_ONE_FQDN}.p12

openssl pkcs12 \
  -in ${ETCD_ONE_FQDN}.p12 \
  -passin pass:${MANAGEMENT_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| sudo tee /var/lib/etcd/${ETCD_ONE_FQDN}.crt

openssl pkcs12 \
  -in ${ETCD_ONE_FQDN}.p12 \
  -passin pass:${MANAGEMENT_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| sudo tee /var/lib/etcd/${ETCD_ONE_FQDN}.key

rm ${ETCD_ONE_FQDN}.p12

# Ensure that the ssl-cert group owns the keypair
sudo chown root:ssl-cert \
  /var/lib/etcd/${ETCD_ONE_FQDN}.crt \
  /var/lib/etcd/${ETCD_ONE_FQDN}.key

# Restrict access to the keypair
sudo chmod 644 /var/lib/etcd/${ETCD_ONE_FQDN}.crt
sudo chmod 640 /var/lib/etcd/${ETCD_ONE_FQDN}.key

sudo usermod -a -G ssl-cert etcd

# Ensure that the following DNS entries are created
dig +noall +answer SRV _etcd-server-ssl._tcp.${ROOT_DNS_DOMAIN}
# Should output
# _etcd-server-ssl._tcp.se.lemche.net. 7197 IN SRV 0 10 2380 etcd-0.se.lemche.net.
# _etcd-server-ssl._tcp.se.lemche.net. 7197 IN SRV 0 10 2380 etcd-1.se.lemche.net.

dig +noall +answer SRV _etcd-client-ssl._tcp.se.lemche.net.
# Should output
# _etcd-client-ssl._tcp.se.lemche.net. 86400 IN SRV 0 10 2379 etcd-0.se.lemche.net.
# _etcd-client-ssl._tcp.se.lemche.net. 86400 IN SRV 0 10 2379 etcd-1.se.lemche.net.

dig +noall +answer ${ETCD_ONE_FQDN} ${ETCD_TWO_FQDN}
# Should output
# etcd-0.se.lemche.net.   6206    IN      A       192.168.1.3
# etcd-1.se.lemche.net.   4340    IN      A       192.168.1.4

sudo mv /etc/default/etcd /etc/default/etcd.$(date +%Y%m%d-%H%M%S)
cat  <<EOF | sudo tee /etc/default/etcd
ETCD_NAME="${ETCD_ONE_FQDN}"
ETCD_DISCOVERY_SRV="${ROOT_DNS_DOMAIN}"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${ETCD_ONE_FQDN}:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
# ETCD_INITIAL_CLUSTER="${ETCD_ONE_FQDN}=https://${ETCD_ONE_FQDN}:2380,${ETCD_TWO_FQDN}=https://${ETCD_TWO_FQDN}:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_ADVERTISE_CLIENT_URLS="https://${ETCD_ONE_FQDN}:2379"
ETCD_LISTEN_CLIENT_URLS="https://0.0.0.0:2379"
ETCD_LISTEN_PEER_URLS="https://0.0.0.0:2380"
ETCD_CERT_FILE="/var/lib/etcd/${ETCD_ONE_FQDN}.crt"
ETCD_KEY_FILE="/var/lib/etcd/${ETCD_ONE_FQDN}.key"
ETCD_TRUSTED_CA_FILE="/etc/ssl/certs/ca-certificates.crt"
ETCD_PEER_CERT_FILE="/var/lib/etcd/${ETCD_ONE_FQDN}.crt"
ETCD_PEER_KEY_FILE="/var/lib/etcd/${ETCD_ONE_FQDN}.key"
ETCD_PEER_TRUSTED_CA_FILE="/etc/ssl/certs/ca-certificates.crt"
EOF
if [[ $(uname --machine) == aarch64 ]]; then
  echo 'ETCD_UNSUPPORTED_ARCH=arm64' | sudo tee -a /etc/default/etcd
fi

sudo systemctl restart etcd

# Setup cluster nodes
ETCD_MEMBER_ID=$(etcdctl --endpoints "https://${ETCD_ONE_FQDN}:2379" member list | grep ${ETCD_ONE_FQDN} | cut -f 1 -d ":")
if [[ -z ${ETCD_ROOT_PASS+x} ]]; then echo "Fetch from root password from secret management"; read ETCD_ROOT_PASS; fi
etcdctl \
  --endpoints "https://${ETCD_ONE_FQDN}:2379" \
  --username root:"$ETCD_ROOT_PASS" \
  member update ${ETCD_MEMBER_ID} https://${ETCD_ONE_FQDN}:2380
etcdctl \
  --endpoints "https://${ETCD_ONE_FQDN}:2379" \
  --username root:"$ETCD_ROOT_PASS" \
  member add ${ETCD_TWO_FQDN} https://${ETCD_TWO_FQDN}:2380
etcdctl \
  --endpoints "https://${ETCD_ONE_FQDN}:2379" \
  member list
