#!/bin/sh

##############################################################################
# Create controller key pair on Controller host
##############################################################################
# Generate controller node key, and certifiate
sudo openssl ca \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -revoke ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_TWO_FQDN}.crt \
  -passin "pass:${CA_PASSWORD}"

sudo su -c "openssl req \
  -batch \
  -config <(cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf; \
    printf \"[SAN]\nsubjectAltName=DNS:${IDM_TWO_FQDN}\") \
  -keyout ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${IDM_TWO_FQDN}.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${IDM_TWO_FQDN}.csr \
  -reqexts SAN \
  -sha256 \
  -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${IDM_TWO_FQDN}\" \
  -subject \
  -utf8"

sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -days 365 \
  -extensions server_cert \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${IDM_TWO_FQDN}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_TWO_FQDN}.crt \
  -passin pass:${CA_PASSWORD}

# Copy controller certificate, and key to OS keystore
sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_TWO_FQDN}.crt \
  -out /etc/ssl/certs/${IDM_TWO_FQDN}.crt
sudo openssl rsa \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${IDM_TWO_FQDN}.key \
  -out /etc/ssl/private/${IDM_TWO_FQDN}.key

# Upload PKCS#12 keystore to vault
export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault login -method=userpass username=admin password=$VAULT_ADMIN_PASS
sudo cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_TWO_FQDN}.p12 \
| base64 \
| vault kv put keystores/${IDM_TWO_FQDN}.p12 data=-

# # Ensure that the ssl-cert group owns the keypair
# sudo su -c "chown root:ssl-cert \
#   /etc/ssl/certs/*.crt \
#   /etc/ssl/private/*.key"
#
# # Restrict access to the keypair
# sudo chmod 644 /etc/ssl/certs/*.crt
# sudo su -c "chmod 640 /etc/ssl/private/*.key"
#
# # Convert PKCS#12 database with the controller keypair
# sudo openssl pkcs12 \
#   -caname "${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME}" \
#   -caname "${SSL_ROOT_CA_COMMON_NAME}" \
#   -certfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
#   -export \
#   -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_TWO_FQDN}.crt \
#   -inkey ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${IDM_TWO_FQDN}.key \
#   -name ${IDM_TWO_FQDN} \
#   -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_TWO_FQDN}.p12 \
#   -passout "pass:${IDM_TWO_KEYSTORE_PASS}"
