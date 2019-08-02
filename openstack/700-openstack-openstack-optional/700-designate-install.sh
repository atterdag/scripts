#!/bin/bash

##############################################################################
# Install Designate on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  designate
