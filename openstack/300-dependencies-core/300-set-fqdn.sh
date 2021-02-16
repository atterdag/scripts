#!/bin/bash

##############################################################################
# Ensure that FQDN is present in /etc/hosts
##############################################################################
if ! grep ${CONTROLLER_FQDN} /etc/hosts > /dev/null; then
  echo -e "${OS_CONTROLLER_IP_ADDRESS}\t${CONTROLLER_FQDN}\t${OS_CONTROLLER_HOST_NAME}" \
  |  sudo tee -a /etc/hosts
fi
if ! grep ${COMPUTE_FQDN} /etc/hosts > /dev/null; then
  echo -e "${OS_COMPUTE_IP_ADDRESS}\t${COMPUTE_FQDN}\t${OS_COMPUTE_HOST_NAME}" \
  | sudo tee -a /etc/hosts
fi
if grep ^127.0.1.1 /etc/hosts > /dev/null; then
  sudo sed -i 's|^127.0.1.1|#127.0.1.1|' /etc/hosts
fi
