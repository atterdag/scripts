#!/bin/bash

##############################################################################
# Install Barbican on Controller host
##############################################################################
# Copy keystore from vault
export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault login -method=userpass username=user password=$(cat ~/.VAULT_USER_PASS)
vault kv get --field=data ephemeral/ca_admin_cert.p12 \
| tr -d '\n' \
| base64 --decode \
| sudo tee /etc/barbican/ca_admin_cert.p12

openssl pkcs12 \
  -in /root/.dogtag/pki-tomcat/ca_admin_cert.p12 \
  -out /etc/barbican/kra_admin_cert.pem \
  -nodes \
  -password pass:$PKI_CLIENT_PKCS12_PASSWORD
chown barbican /etc/barbican/kra_admin_cert.pem
