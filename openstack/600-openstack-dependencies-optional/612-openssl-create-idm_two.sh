#!/bin/bash

##############################################################################
# Create controller key pair on Controller host
##############################################################################
if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
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

  # Upload PKCS#12 keystore to etcd
  export ETCDCTL_ENDPOINTS="https://${CONTROLLER_FQDN}:4100"
  if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read ETCD_ADMIN_PASS; fi
  sudo cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${IDM_TWO_FQDN}.p12 \
  | base64 \
  | etcdctl --username admin:"$ETCD_ADMIN_PASS" set /keystores/IDM_TWO_FQDN
fi
