#!/bin/bash

##############################################################################
# Install Nova on Compute host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  nova-compute
