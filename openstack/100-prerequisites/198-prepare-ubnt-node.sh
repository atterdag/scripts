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

# Get UBNT keystore
etcdctl --username user:$ETCD_USER_PASS get /keystores/UBNT.p12 \
| tr -d '\n' \
| base64 --decode \
> ${UBNT_FQDN}.p12

ssh ${UBNT_FQDN} "if [[ ! -d /config/auth/certificates ]]; then sudo mkdir /config/auth/certificates; fi"

openssl pkcs12 \
  -in ${UBNT_FQDN}.p12 \
  -passin pass:${UBNT_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| ssh ${UBNT_FQDN} "sudo tee /config/auth/certificates/${UBNT_FQDN}.crt"

openssl pkcs12 \
  -in ${UBNT_FQDN}.p12 \
  -passin pass:${UBNT_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| grep -v '^\(^Bag\|^.*friendlyName\|^.*localKeyID\|^Key\|^$\)' \
| ssh ${UBNT_FQDN} "sudo tee -a /config/auth/certificates/${UBNT_FQDN}.crt"

openssl pkcs12 \
  -in ${UBNT_FQDN}.p12 \
  -passin pass:${UBNT_KEYSTORE_PASS} \
  -nokeys \
  -cacerts \
| grep -v '^\(^Bag\|^subject\|^issuer\|^.*friendlyName\|^.*localKeyID\|^$\)' \
| ssh ${UBNT_FQDN} "sudo tee /config/auth/certificates/ca-chain.crt"

ssh ${UBNT_FQDN} "sudo chmod 640 /config/auth/certificates/${UBNT_FQDN}.crt"

rm -f ${UBNT_FQDN}.p12

cat <<EOF
# Run the following commands on router
configure
set service gui ca-file /config/auth/certificates/ca-chain.crt
set service gui cert-file /config/auth/certificates/${UBNT_FQDN}.crt
set service gui older-ciphers disable
save
exit
sudo  kill -SIGTERM $(cat /var/run/lighttpd.pid)
sudo /usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
EOF
