#!/bin/bash

##############################################################################
# Enable SSL for etcd on MANAGEMENT host
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
  etcd \
  ca-certificates \
  html2text \
  ssl-cert

if [[ $(uname --machine) == aarch64 ]]; then
  if [[ -f /usr/sbin/policy-rc.d ]]; then
    sudo rm -f /usr/sbin/policy-rc.d
  fi
fi

cat <<EOF | sudo tee /etc/ufw/applications.d/etcd
[etcd]
title=etcd
description=A distributed, reliable key-value store for the most critical data of a distributed system.
ports=2379,2380/tcp
EOF

sudo ufw allow etcd

# You have to set these by hand
export ETCD_ONE_FQDN=etcd-0.se.lemche.net
export SSL_ROOT_CA_FQDN=ca.se.lemche.net

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
export ETCDCTL_DISCOVERY_SRV="$(hostname -d)"
for key in $(etcdctl ls variables/ | sed 's|^/variables/||'); do
	export eval $key="$(etcdctl get variables/$key)"
done

# Create variables with secrets
for secret in $(etcdctl --username user:$ETCD_USER_PASS ls /passwords/ | sed 's|^/passwords/||'); do
	export eval $secret="$(etcdctl --username user:$ETCD_USER_PASS get /passwords/$secret)"
done

# Retrieve MANAGEMENT keystore from etcd
etcdctl --username user:$ETCD_USER_PASS get /keystores/ETCD_TWO.p12 \
| tr -d '\n' \
| base64 --decode \
> ${ETCD_TWO_FQDN}.p12

openssl pkcs12 \
  -in ${ETCD_TWO_FQDN}.p12 \
  -passin pass:${MANAGEMENT_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| sudo tee /var/lib/etcd/${ETCD_TWO_FQDN}.crt

openssl pkcs12 \
  -in ${ETCD_TWO_FQDN}.p12 \
  -passin pass:${MANAGEMENT_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| sudo tee /var/lib/etcd/${ETCD_TWO_FQDN}.key

rm -f ${ETCD_TWO_FQDN}.p12

# Ensure that the ssl-cert group owns the keypair
sudo chown root:ssl-cert \
  /var/lib/etcd/${ETCD_TWO_FQDN}.crt \
  /var/lib/etcd/${ETCD_TWO_FQDN}.key

# Restrict access to the keypair
sudo chmod 644 /var/lib/etcd/${ETCD_TWO_FQDN}.crt
sudo chmod 640 /var/lib/etcd/${ETCD_TWO_FQDN}.key

sudo usermod -a -G ssl-cert etcd

sudo mv /etc/default/etcd /etc/default/etcd.$(date +%Y%m%d-%H%M%S)
cat  <<EOF | sudo tee /etc/default/etcd
ETCD_NAME="${ETCD_TWO_FQDN}"
ETCD_DISCOVERY_SRV="${DNS_DOMAIN}"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${ETCD_TWO_FQDN}:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="existing"
# ETCD_INITIAL_CLUSTER="${ETCD_TWO_FQDN}=https://${ETCD_TWO_FQDN}:2380,${ETCD_ONE_FQDN}=https://${ETCD_ONE_FQDN}:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://${ETCD_TWO_FQDN}:2379"
ETCD_LISTEN_CLIENT_URLS="https://0.0.0.0:2379"
ETCD_LISTEN_PEER_URLS="https://0.0.0.0:2380"
ETCD_CERT_FILE="/var/lib/etcd/${ETCD_TWO_FQDN}.crt"
ETCD_KEY_FILE="/var/lib/etcd/${ETCD_TWO_FQDN}.key"
ETCD_TRUSTED_CA_FILE="/etc/ssl/certs/ca-certificates.crt"
ETCD_PEER_CERT_FILE="/var/lib/etcd/${ETCD_TWO_FQDN}.crt"
ETCD_PEER_KEY_FILE="/var/lib/etcd/${ETCD_TWO_FQDN}.key"
ETCD_PEER_TRUSTED_CA_FILE="/etc/ssl/certs/ca-certificates.crt"
EOF
if [[ $(uname --machine) == aarch64 ]]; then
  echo 'ETCD_UNSUPPORTED_ARCH=arm64' | sudo tee -a /etc/default/etcd
fi

sudo systemctl enable etcd
sudo systemctl start etcd

# Check the cluster-health
etcdctl --debug cluster-health

# Check that cluster works by running the following a few times
etcdctl --debug get /variables/ETCD_ONE_FQDN
