#!/bin/bash

##############################################################################
# Install Neutron on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  neutron-server \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent \
  neutron-l3-agent
