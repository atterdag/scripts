#!/bin/bash

##############################################################################
# Install Barbican on Controller host
##############################################################################
# Copy keystore to etcd
export ETCDCTL_ENDPOINTS="https://${CONTROLLER_FQDN}:4100"
if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read -s ETCD_ADMIN_PASS; fi
sudo cat /root/.dogtag/pki-tomcat/ca_admin_cert.p12 \
| base64 \
| tr -d '\n' \
| etcdctl --username admin:"$ETCD_ADMIN_PASS" mk ephemeral/ca_admin_cert.p12
