#!/bin/bash

##############################################################################
# Install Barbican on Controller host
##############################################################################

sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  barbican-api \
  barbican-keystone-listener \
  barbican-worker \
  pki-base
