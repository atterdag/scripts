#!/bin/bash

##############################################################################
# Create controller key pair on Controller host
##############################################################################
if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  # Generate controller node key, and certifiate
  sudo openssl ca \
    -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
    -revoke ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_ONE_FQDN}.crt \
    -passin "pass:${CA_PASSWORD}"

  sudo su -c "openssl req \
    -batch \
    -config <(cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf; \
      printf \"[SAN]\nsubjectAltName=DNS:${NS_FQDN}\") \
    -keyout ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${IDM_ONE_FQDN}.key \
    -new \
    -newkey rsa:2048 \
    -nodes \
    -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${IDM_ONE_FQDN}.csr \
    -reqexts SAN \
    -sha256 \
    -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${IDM_ONE_FQDN}\" \
    -subject \
    -utf8"

  sudo openssl ca \
    -batch \
    -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
    -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
    -days 365 \
    -extensions server_cert \
    -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${IDM_ONE_FQDN}.csr \
    -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
    -keyform PEM \
    -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_ONE_FQDN}.crt \
    -passin pass:${CA_PASSWORD}

  # Convert PKCS#12 database with the controller keypair
  sudo openssl pkcs12 \
    -caname "${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME}" \
    -caname "${SSL_ROOT_CA_COMMON_NAME}" \
    -certfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
    -export \
    -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_ONE_FQDN}.crt \
    -inkey ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${IDM_ONE_FQDN}.key \
    -name ${IDM_ONE_FQDN} \
    -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_ONE_FQDN}.p12 \
    -passout "pass:${IDM_ONE_KEYSTORE_PASS}"

  # Upload PKCS#12 keystore to vault
  export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
  vault login -method=userpass username=admin password=$VAULT_ADMIN_PASS
  sudo cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_ONE_FQDN}.p12 \
  | base64 \
  | vault kv put keystores/${IDM_ONE_FQDN}.p12 data=-
fi
