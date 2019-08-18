#!/bin/bash

##############################################################################
# Remove all Python modules installed by pip, and reset to package versions
##############################################################################
sudo apt-get --yes --quiet install \
  lvm2 \
  thin-provisioning-tools
sudo vgremove --force --yes \
  cinder-standard-vg \
  cinder-premium-vg
