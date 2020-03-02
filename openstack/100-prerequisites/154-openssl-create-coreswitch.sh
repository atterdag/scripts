#!/bin/bash

##############################################################################
# Create controller key pair on Controller host
##############################################################################
# Generate controller node key, and certifiate
# sudo openssl ca \
#   -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
#   -revoke ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CORESWITCH_FQDN}.crt \
#   -passin "pass:${CA_PASSWORD}"

export ETCDCTL_ENDPOINTS="https://${MANAGEMENT_FQDN}:2379"

ETCD_ADMIN_PASS=$(cat ~/.ETCD_ADMIN_PASS)

etcdctl mk variables/CORESWITCH_HOST_NAME 'coreswitch'
etcdctl mk variables/CORESWITCH_FQDN "$(etcdctl get variables/CORESWITCH_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/CORESWITCH_IP_ADDRESS '192.168.0.4'

etcdctl --username admin:"$ETCD_ADMIN_PASS" mk /passwords/CORESWITCH_KEYSTORE_PASS $(genpasswd 16)

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
| etcdctl --username admin:"$ETCD_ADMIN_PASS" mk keystores/${CORESWITCH_FQDN}.p12
