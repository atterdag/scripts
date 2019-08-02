#!/bin/bash

##############################################################################
# Ensure that FQDN is present in /etc/hosts
##############################################################################
if ! grep $CONTROLLER_FQDN /etc/hosts > /dev/null; then
  echo -e "$CONTROLLER_IP_ADDRESS\t$CONTROLLER_FQDN\t$(echo $CONTROLLER_FQDN \
  | awk -F'.' '{print $1}')" \
  |  sudo tee -a /etc/hosts
elif ! grep $COMPUTE_FQDN /etc/hosts > /dev/null; then
  echo -e "$COMPUTE_IP_ADDRESS\t$COMPUTE_FQDN\t$(echo $COMPUTE_FQDN \
  | awk -F'.' '{print $1}')" \
  | sudo tee -a /etc/hosts
fi
