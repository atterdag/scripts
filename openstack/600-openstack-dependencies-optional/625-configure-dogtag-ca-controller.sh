#!/bin/bash

##############################################################################
# Receive CSR, and sign it on CA host
##############################################################################
# sudo openssl ca \
#   -config ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/openssl.cnf \
#   -revoke ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
#   -passin "pass:${CA_PASSWORD}"

export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault login -method=userpass username=user password=$VAULT_USER_PASS
vault kv get --field=data ephemeral/ca_signing.csr \
| tr -d '\n' \
| base64 --decode \
| sudo tee ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.csr

sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/openssl.cnf \
  -days 3650 \
  -extensions v3_intermediate_ca \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private/${SSL_ROOT_CA_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
  -passin pass:${CA_PASSWORD} \
  -policy policy_anything

sudo cat ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
| base64 \
| tr -d '\n' \
| vault kv put ephemeral/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt data=-
