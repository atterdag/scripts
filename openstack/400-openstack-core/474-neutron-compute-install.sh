#!/bin/sh

##############################################################################
# Install Neutron on Compute host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  neutron-linuxbridge-agent
