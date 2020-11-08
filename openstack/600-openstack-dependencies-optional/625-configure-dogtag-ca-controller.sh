#!/bin/bash

##############################################################################
# Receive CSR, and sign it on CA host
##############################################################################
if [[ -f ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt ]]; then
  sudo openssl ca \
    -config ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/openssl.cnf \
    -revoke ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
    -passin "pass:${CA_PASSWORD}"
fi

export ETCDCTL_DISCOVERY_SRV="$(hostname -d)"
if [[ -z ${ETCD_USER_PASS+x} ]]; then echo "Fetch from user password from secret management"; read -s ETCD_USER_PASS; fi
if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read -s ETCD_ADMIN_PASS; fi

etcdctl --username user:$ETCD_USER_PASS get ephemeral/ca_signing.csr \
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

if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read -s ETCD_ADMIN_PASS; fi
sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
| base64 \
| tr -d '\n' \
| etcdctl --username admin:"$ETCD_ADMIN_PASS" set ephemeral/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt
