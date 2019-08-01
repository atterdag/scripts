#!/bin/sh

##############################################################################
# Install Barbican on Controller host
##############################################################################
# Copy keystore to vault
export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault login -method=userpass username=user password=$VAULT_USER_PASS
sudo cat /root/.dogtag/pki-tomcat/ca_admin_cert.p12 \
| base64 \
| tr -d '\n' \
| vault kv put ephemeral/ca_admin_cert.p12 data=-