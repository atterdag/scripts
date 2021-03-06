#!/bin/bash

##############################################################################
# Install Designate on Controller host
##############################################################################
if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  ssh_cmd="ssh -o StrictHostKeyChecking=no ubuntu@${NS_IP_ADDRESS}"
else
  ssh_cmd=""
fi
$ssh_cmd sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  designate \
  crudini \
  ssl-cert
