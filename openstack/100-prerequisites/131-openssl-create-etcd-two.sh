#!/bin/bash

##############################################################################
# Create controller key pair on Controller host
##############################################################################

# Revoke certificate if existing
if [[ -f ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${ETCD_TWO_FQDN}.crt ]]; then
  sudo openssl ca \
    -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
    -revoke ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${ETCD_TWO_FQDN}.crt \
    -passin "pass:${CA_PASSWORD}"
fi

sudo su -c "openssl req \
  -batch \
  -config <(cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf; \
    printf \"[SAN]\nsubjectAltName=DNS:${ETCD_TWO_FQDN},IP:${ETCD_TWO_IP_ADDRESS},DNS:${DNS_DOMAIN}\") \
  -keyout ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${ETCD_TWO_FQDN}.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${ETCD_TWO_FQDN}.csr \
  -reqexts SAN \
  -sha256 \
  -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${ETCD_TWO_FQDN}\" \
  -subject \
  -utf8"

sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -days 365 \
  -extensions server_cert \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${ETCD_TWO_FQDN}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${ETCD_TWO_FQDN}.crt \
  -passin pass:${CA_PASSWORD}

# Convert PKCS#12 database with the controller keypair
sudo openssl pkcs12 \
  -caname "${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME}" \
  -caname "${SSL_ROOT_CA_COMMON_NAME}" \
  -certfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
  -export \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${ETCD_TWO_FQDN}.crt \
  -inkey ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${ETCD_TWO_FQDN}.key \
  -name ${ETCD_TWO_FQDN} \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${ETCD_TWO_FQDN}.p12 \
  -passout "pass:${MANAGEMENT_KEYSTORE_PASS}"

# Upload PKCS#12 keystore to etcd
export ETCDCTL_ENDPOINTS="http://localhost:2379"
if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read -s ETCD_ADMIN_PASS; fi
sudo cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${ETCD_TWO_FQDN}.p12 \
| base64 \
| etcdctl --username admin:"$ETCD_ADMIN_PASS" set /keystores/ETCD_TWO.p12
