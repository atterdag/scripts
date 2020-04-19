#!/bin/bash

##############################################################################
# Ensure that FQDN is present in /etc/hosts
##############################################################################
if ! grep ${MANAGEMENT_FQDN} /etc/hosts > /dev/null; then
  echo -e "${MANAGEMENT_IP_ADDRESS}\t${MANAGEMENT_FQDN}\t${MANAGEMENT_HOST_NAME}" \
  |  sudo tee -a /etc/hosts
fi
if grep ^127.0.1.1 /etc/hosts > /dev/null; then
  sudo sed -i 's|^127.0.1.1|#127.0.1.1|' /etc/hosts
fi
