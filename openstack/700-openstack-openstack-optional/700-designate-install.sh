#!/bin/bash

##############################################################################
# Install Designate on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  designate
