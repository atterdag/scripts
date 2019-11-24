#!/bin/bash

##############################################################################
# Install dependencies that are not automatically installed
##############################################################################
sudo apt-get --yes --quiet install \
  arptables \
  crudini \
  ebtables \
  lvm2 \
  python-pip \
  thin-provisioning-tools
