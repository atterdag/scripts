#!/bin/bash

##############################################################################
# Setting up other nodes
##############################################################################
# You have to set these by hand
export SSL_ROOT_CA_FQDN=ca.se.lemche.net
if [[ -z ${ETCD_USER_PASS+x} ]]; then echo "Fetch from user password from secret management"; read -s ETCD_USER_PASS; fi

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

# Get registry keystore
etcdctl --username user:$ETCD_USER_PASS get /keystores/REGISTRY.p12 \
| tr -d '\n' \
| base64 --decode \
> ${REGISTRY_FQDN}.p12

openssl pkcs12 \
  -in ${REGISTRY_FQDN}.p12 \
  -passin pass:${REGISTRY_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| sudo tee /etc/ssl/certs/${REGISTRY_FQDN}.crt

openssl pkcs12 \
  -in ${REGISTRY_FQDN}.p12 \
  -passin pass:${REGISTRY_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| sudo tee /etc/ssl/private/${REGISTRY_FQDN}.key

sudo chown root:ssl-cert \
  /etc/ssl/certs/${REGISTRY_FQDN}.crt \
  /etc/ssl/private/${REGISTRY_FQDN}.key

sudo chmod 644 /etc/ssl/certs/${REGISTRY_FQDN}.crt
sudo chmod 640 /etc/ssl/private/${REGISTRY_FQDN}.key

rm -f ${REGISTRY_FQDN}.p12
