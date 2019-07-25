#!/bin/sh

##############################################################################
# Install dependencies that are not automatically installed
##############################################################################
sudo apt-get --yes install \
  arptables \
  ebtables \
  lvm2 \
  python-pip \
  thin-provisioning-tools
