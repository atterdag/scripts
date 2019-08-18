#!/bin/bash

##############################################################################
# Create debian server instance on Controller host
##############################################################################
if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  ssh_cmd="ssh -o StrictHostKeyChecking=no ubuntu@${NS_IP_ADDRESS}"
  $ssh_cmd sudo apt-get --yes --quiet install \
    software-properties-common
  $ssh_cmd sudo add-apt-repository --yes \
    cloud-archive:rocky
  $ssh_cmd sudo apt-get update
  $ssh_cmd sudo apt-get --yes dist-upgrade
fi
