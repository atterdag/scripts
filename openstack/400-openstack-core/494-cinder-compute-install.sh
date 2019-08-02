#!/bin/bash

##############################################################################
# Install Cinder on Compute host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  # cinder-backup \
  cinder-volume \
  tgt \
  lvm2 \
  thin-provisioning-tools
