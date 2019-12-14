#!/bin/bash

##############################################################################
# Install Barbican on Controller host
##############################################################################
# Copy keystore from etcd
export ETCDCTL_ENDPOINTS="https://${CONTROLLER_FQDN}:4100"
ETCD_USER_PASS=$(cat ~/.ETCD_USER_PASS)
etcdctl --username user:$ETCD_USER_PASS get ephemeral/ca_admin_cert.p12 \
| tr -d '\n' \
| base64 --decode \
| sudo tee /etc/barbican/ca_admin_cert.p12

openssl pkcs12 \
  -in /root/.dogtag/pki-tomcat/ca_admin_cert.p12 \
  -out /etc/barbican/kra_admin_cert.pem \
  -nodes \
  -password pass:$PKI_CLIENT_PKCS12_PASSWORD
chown barbican /etc/barbican/kra_admin_cert.pem
