#!/bin/bash

echo '***'
echo '*** Prepare files to upload to switch'
echo '***'
export ETCDCTL_DISCOVERY_SRV="$(hostname -d)"

if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read -s ETCD_ADMIN_PASS; fi

etcdctl --username user:$ETCD_USER_PASS get /ca/dhparams-strong.pem \
> dhparams-strong.pem

etcdctl --username user:$ETCD_USER_PASS get /ca/dhparams-weak.pem \
> dhparams-weak.pem

etcdctl --username user:$ETCD_USER_PASS get /ca/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
> ca-chain.pem

etcdctl --username user:$ETCD_USER_PASS get /keystores/CORESWITCH_FQDN \
| tr -d '\n' \
| base64 --decode \
> ${CORESWITCH_FQDN}.p12

openssl pkcs12 \
  -in ${CORESWITCH_FQDN}.p12 \
  -passin pass:${CORESWITCH_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| tee switch-combined.pem

openssl pkcs12 \
  -in ${CORESWITCH_FQDN}.p12 \
  -passin pass:${CORESWITCH_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| openssl rsa 2>/dev/null \
| tee -a switch-combined.pem

rm -f ${CORESWITCH_FQDN}.p12

# In the switch’s web UI:
#
# Security → Access → HTTPS → HTTPS Configuration → Set “HTTPS Admin Mode” to “Disable”, Apply.
# Security → Access → HTTPS → Certificate Management → Set “Delete Certificates”, Apply.
# Maintenance → Download → HTTP File Download
# Select “SSL DH Strong Encryption Parameter PEM File”, and choose dhparams.pem, Apply.
# Select “SSL Trusted Root Certificate PEM File”, and choose ca-chain.pem, Apply.
# Select “SSL Server Certificate PEM File”, and choose switch-combined.pem, Apply.
# Security → Access → HTTPS → Certificate Management → Verify indicates “Certificate Present: Yes”.
# Security → Access → HTTPS → HTTPS Configuration → Set “HTTPS Admin Mode” to “Enable”, Apply.
