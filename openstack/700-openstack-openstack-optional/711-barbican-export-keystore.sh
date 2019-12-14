#!/bin/bash

##############################################################################
# Install Barbican on Controller host
##############################################################################
# Copy keystore to etcd
export ETCDCTL_ENDPOINTS="https://${CONTROLLER_FQDN}:4100"
ETCD_ADMIN_PASS=$(cat ~/.ETCD_ADMIN_PASS)
sudo cat /root/.dogtag/pki-tomcat/ca_admin_cert.p12 \
| base64 \
| tr -d '\n' \
| etcdctl --username admin:"$ETCD_ADMIN_PASS" mk ephemeral/ca_admin_cert.p12
