#!/bin/bash

##############################################################################
# Ensure that FQDN is present in /etc/hosts
##############################################################################
if ! grep ${ETCD_ONE_FQDN} /etc/hosts > /dev/null; then
  echo -e "${ETCD_ONE_IP_ADDRESS}\t${ETCD_ONE_FQDN}\t${ETCD_ONE_HOST_NAME}" \
  |  sudo tee -a /etc/hosts
fi
if ! grep ${ETCD_TWO_FQDN} /etc/hosts > /dev/null; then
  echo -e "${ETCD_TWO_IP_ADDRESS}\t${ETCD_TWO_FQDN}\t${ETCD_TWO_HOST_NAME}" \
  |  sudo tee -a /etc/hosts
fi
if grep ^127.0.1.1 /etc/hosts > /dev/null; then
  sudo sed -i 's|^127.0.1.1|#127.0.1.1|' /etc/hosts
fi
