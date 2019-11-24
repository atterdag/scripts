#!/bin/bash

##############################################################################
# Remove all Python modules installed by pip, and reset to package versions
##############################################################################
sudo apt-get --yes --quiet install \
  lvm2
sudo vgremove --force --yes \
  cinder-standard-vg \
  cinder-premium-vg
