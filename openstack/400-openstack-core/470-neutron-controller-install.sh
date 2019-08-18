#!/bin/bash

##############################################################################
# Install Neutron on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  neutron-dhcp-agent \
  neutron-l3-agent \
  neutron-linuxbridge-agent \
  neutron-metadata-agent \
  neutron-plugin-ml2 \
  neutron-server
