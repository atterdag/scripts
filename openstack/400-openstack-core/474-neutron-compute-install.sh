#!/bin/bash

##############################################################################
# Install Neutron on Compute host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  neutron-linuxbridge-agent
