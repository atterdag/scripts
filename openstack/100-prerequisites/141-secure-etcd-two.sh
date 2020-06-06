#!/bin/bash

##############################################################################
# Enable SSL for etcd on MANAGEMENT host
##############################################################################

sudo apt-get --yes --quiet install \
  ca-certificates \
  html2text \
  ssl-cert

# You have to set these by hand
export ETCD_ONE_FQDN=dexter.se.lemche.net
export SSL_ROOT_CA_FQDN=ca.se.lemche.net
 export ETCD_USER_PASS=

# Get read privileges to etcd
if [[ -z ${ETCD_USER_PASS+x} ]]; then echo "Fetch from user password from secret management"; read ETCD_USER_PASS; fi

# Get list of CA certifiates
CA_CERTIFICATES=$(curl \
  --silent \
	http://${SSL_ROOT_CA_FQDN}/ \
| html2text \
| grep .crt \
| awk '{print $3}')

# Download each CA certificate
for ca_certificate in $CA_CERTIFICATES; do
	sudo curl \
	  --output /usr/local/share/ca-certificates/${ca_certificate} \
		--silent \
	  http://${SSL_ROOT_CA_FQDN}/${ca_certificate}
done

# Update OS truststore
sudo update-ca-certificates \
  --verbose \
  --fresh

# Create variables with infrastructure configuration
export ETCDCTL_ENDPOINTS="https://${ETCD_ONE_FQDN}:2379"
for key in $(etcdctl ls variables/ | sed 's|^/variables/||'); do
	export eval $key="$(etcdctl get variables/$key)"
done

# Create variables with secrets
for secret in $(etcdctl --username user:$ETCD_USER_PASS ls /passwords/ | sed 's|^/passwords/||'); do
	export eval $secret="$(etcdctl --username user:$ETCD_USER_PASS get /passwords/$secret)"
done

# Retrieve MANAGEMENT keystore from etcd
etcdctl --username user:$ETCD_USER_PASS get /keystores/${ETCD_TWO_FQDN}.p12 \
| tr -d '\n' \
| base64 --decode \
> ${ETCD_TWO_FQDN}.p12

openssl pkcs12 \
  -in ${ETCD_TWO_FQDN}.p12 \
  -passin pass:${MANAGEMENT_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| sudo tee /etc/ssl/certs/${ETCD_TWO_FQDN}.crt

openssl pkcs12 \
  -in ${ETCD_TWO_FQDN}.p12 \
  -passin pass:${MANAGEMENT_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| sudo tee /etc/ssl/private/${ETCD_TWO_FQDN}.key

# Ensure that the ssl-cert group owns the keypair
sudo chown root:ssl-cert \
  /etc/ssl/certs/${ETCD_TWO_FQDN}.crt \
  /etc/ssl/private/${ETCD_TWO_FQDN}.key

# Restrict access to the keypair
sudo chmod 644 /etc/ssl/certs/${ETCD_TWO_FQDN}.crt
sudo chmod 640 /etc/ssl/private/${ETCD_TWO_FQDN}.key

cat  <<EOF | sudo sed --file - --in-place /etc/default/etcd
s|^.*ETCD_NAME=.*|ETCD_NAME=\"${ETCD_TWO_FQDN}\"|
s|^.*ETCD_DATA_DIR=.*|ETCD_DATA_DIR=\"/var/lib/etcd/default\"|
s|^.*ETCD_LISTEN_PEER_URLS=.*|ETCD_LISTEN_PEER_URLS=\"https://${ETCD_TWO_IP_ADDRESS}:2380\"|
s|^.*ETCD_LISTEN_CLIENT_URLS=.*|ETCD_LISTEN_CLIENT_URLS=\"https://${ETCD_TWO_IP_ADDRESS}:2379\"|
s|^.*ETCD_INITIAL_ADVERTISE_PEER_URLS=.*|ETCD_INITIAL_ADVERTISE_PEER_URLS=\"https://${ETCD_TWO_FQDN}:2380\"|
s|^.*ETCD_INITIAL_CLUSTER=.*|ETCD_INITIAL_CLUSTER=\"default=https://${ETCD_TWO_FQDN}:2380\"|
s|^.*ETCD_ADVERTISE_CLIENT_URLS=.*|ETCD_ADVERTISE_CLIENT_URLS=\"https://${ETCD_TWO_FQDN}:2379\"|
s|^.*ETCD_CERT_FILE.*|ETCD_CERT_FILE=\"/etc/ssl/certs/${ETCD_TWO_FQDN}.crt\"|
s|^.*ETCD_KEY_FILE.*|ETCD_KEY_FILE=\"/etc/ssl/private/${ETCD_TWO_FQDN}.key\"|
s|^.*ETCD_PEER_CERT_FILE.*|ETCD_PEER_CERT_FILE=\"/etc/ssl/certs/${ETCD_TWO_FQDN}.crt\"|
s|^.*ETCD_PEER_KEY_FILE.*|ETCD_PEER_KEY_FILE=\"/etc/ssl/private/${ETCD_TWO_FQDN}.key\"|
EOF

sudo usermod -a -G ssl-cert etcd

sudo systemctl restart etcd
