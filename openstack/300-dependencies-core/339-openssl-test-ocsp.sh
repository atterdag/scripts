#!/bin/sh

##############################################################################
# Test OpenSSL OCSP on Controller host
##############################################################################
# Generate new CRL
sudo openssl ca \
  -batch \
  -gencrl \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/ca.crl \
  -passin pass:${CA_PASSWORD}

# Take note of the CA_PASSWORD
echo ${CA_PASSWORD}

# Test OCSP
sudo openssl ocsp \
  -index ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/index.txt \
  -port 2560 \
  -rsigner ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.crt \
  -rkey ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.key \
  -CA ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
  -text \
  -nrequest 1 \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.log

# Test in another terminal
sudo openssl ocsp \
  -CAfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
  -url http://127.0.0.1:2560 \
  -resp_text \
  -issuer ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.crt \
  -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CONTROLLER_FQDN}.crt
