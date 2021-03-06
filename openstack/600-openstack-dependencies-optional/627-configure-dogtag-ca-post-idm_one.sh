#!/bin/bash

##############################################################################
# Install DogTag
##############################################################################
sudo certutil \
  -L \
  -d /etc/pki/${SSL_PKI_INSTANCE_NAME}/alias
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-init
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-cert-import \
  --ca-cert /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/${SSL_ROOT_CA_STRICT_NAME}.crt
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-cert-import \
  "${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME}" \
  --ca-cert /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.crt
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-cert-import \
  --pkcs12 /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_admin_cert.p12 \
  --pkcs12-password-file /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca/pkcs12_password.conf
# This doesn't work
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  -d /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_admin_cert.p12 \
  -n caadmin \
  ca-user-show \
  caadmin
