#!/bin/bash

##############################################################################
# Install Neutron on Compute host
##############################################################################
if [[ $CONTROLLER_FQDN != $COMPUTE_FQDN ]]; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
    neutron-linuxbridge-agent
fi
