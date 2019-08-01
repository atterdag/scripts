#!/bin/sh

##############################################################################
# Install Neutron on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  neutron-server \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent \
  neutron-l3-agent
