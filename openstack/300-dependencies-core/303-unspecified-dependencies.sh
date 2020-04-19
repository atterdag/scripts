#!/bin/bash

##############################################################################
# Install dependencies that are not automatically installed
##############################################################################
sudo apt-get --yes --quiet install \
  arptables \
  crudini \
  ebtables \
  ssl-cert \
  lvm2 \
  thin-provisioning-tools

# sudo apt-get --yes --quiet install \
#   python-pip \
