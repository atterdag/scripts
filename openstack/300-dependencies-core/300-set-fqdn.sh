#!/bin/bash

##############################################################################
# Ensure that FQDN is present in /etc/hosts
##############################################################################
if ! grep ${CONTROLLER_FQDN} /etc/hosts > /dev/null; then
  echo -e "${CONTROLLER_IP_ADDRESS}\t${CONTROLLER_FQDN}\t${CONTROLLER_HOST_NAME}" \
  |  sudo tee -a /etc/hosts
fi
if ! grep ${COMPUTE_FQDN} /etc/hosts > /dev/null; then
  echo -e "${COMPUTE_IP_ADDRESS}\t${COMPUTE_FQDN}\t${COMPUTE_HOST_NAME}" \
  | sudo tee -a /etc/hosts
fi
