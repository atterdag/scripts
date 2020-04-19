#!/bin/bash

##############################################################################
# Create controller key pair on Controller host
##############################################################################
export ETCDCTL_ENDPOINTS="https://${MANAGEMENT_FQDN}:2379"

ETCD_ADMIN_PASS=$(cat ~/.ETCD_ADMIN_PASS)

etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CORESWITCH_HOST_NAME 'coreswitch'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CORESWITCH_FQDN "$(etcdctl get variables/CORESWITCH_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CORESWITCH_IP_ADDRESS '192.168.0.4'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/CORESWITCH_KEYSTORE_PASS $(genpasswd 16)

# Set environment variables
for key in $(etcdctl ls /variables/ | sed 's|^/variables/||'); do
	export eval $key="$(etcdctl get /variables/$key)"
done

# Get read privileges to etcd
ETCD_USER_PASS=$(cat ~/.ETCD_USER_PASS)

# Create variables with secrets
for secret in $(etcdctl --username user:$ETCD_USER_PASS ls /passwords/ | sed 's|^/passwords/||'); do
	export eval $secret="$(etcdctl --username user:$ETCD_USER_PASS get /passwords/$secret)"
done

# Revoke certificate if existing
if [[ -f ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CORESWITCH_FQDN}.crt ]]; then
	sudo openssl ca \
	  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
	  -revoke ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CORESWITCH_FQDN}.crt \
	  -passin "pass:${CA_PASSWORD}"
fi

sudo su -c "openssl req \
  -batch \
  -config <(cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf; \
    printf \"[SAN]\nsubjectAltName=DNS:${CORESWITCH_FQDN}\") \
  -keyout ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${CORESWITCH_FQDN}.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${CORESWITCH_FQDN}.csr \
  -reqexts SAN \
  -sha256 \
  -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${CORESWITCH_FQDN}\" \
  -subject \
  -utf8"

sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -days 365 \
  -extensions server_cert \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${CORESWITCH_FQDN}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CORESWITCH_FQDN}.crt \
  -passin pass:${CA_PASSWORD}

# Convert PKCS#12 database with the controller keypair
sudo openssl pkcs12 \
  -caname "${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME}" \
  -caname "${SSL_ROOT_CA_COMMON_NAME}" \
  -certfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
  -export \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CORESWITCH_FQDN}.crt \
  -inkey ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${CORESWITCH_FQDN}.key \
  -name ${CORESWITCH_FQDN} \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CORESWITCH_FQDN}.p12 \
  -passout "pass:${CORESWITCH_KEYSTORE_PASS}"

# Upload PKCS#12 keystore to etcd
sudo cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CORESWITCH_FQDN}.p12 \
| base64 \
| etcdctl --username admin:"$ETCD_ADMIN_PASS" set /keystores/${CORESWITCH_FQDN}.p12


##############################################################################
# Prepare files to upload to switch
##############################################################################
etcdctl --username user:$ETCD_USER_PASS get /ca/dhparams-strong.pem \
> dhparams-strong.pem

etcdctl --username user:$ETCD_USER_PASS get /ca/dhparams-weak.pem \
> dhparams-weak.pem

etcdctl --username user:$ETCD_USER_PASS get /ca/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
> ca-chain.pem

etcdctl --username user:$ETCD_USER_PASS get /keystores/${CORESWITCH_FQDN}.p12 \
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
