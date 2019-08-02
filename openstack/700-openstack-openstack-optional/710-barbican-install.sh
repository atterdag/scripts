#!/bin/bash

##############################################################################
# Install Barbican on Controller host
##############################################################################

sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  barbican-api \
  barbican-keystone-listener \
  barbican-worker \
  pki-base
