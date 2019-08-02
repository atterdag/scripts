#!/bin/bash

##############################################################################
# Install Glance on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  glance
