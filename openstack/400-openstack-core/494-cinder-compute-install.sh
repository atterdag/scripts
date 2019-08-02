#!/bin/bash

##############################################################################
# Install Cinder on Compute host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  cinder-volume \
  tgt \
  lvm2 \
  thin-provisioning-tools
