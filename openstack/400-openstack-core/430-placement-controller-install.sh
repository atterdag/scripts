#!/bin/bash

##############################################################################
# Install Nova on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  placement-api \
  python3-placement
