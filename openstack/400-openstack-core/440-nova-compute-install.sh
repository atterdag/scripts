#!/bin/bash

##############################################################################
# Install Nova on Compute host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  nova-compute
