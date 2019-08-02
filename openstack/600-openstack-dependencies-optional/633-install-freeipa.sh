#!/bin/bash

##############################################################################
# Install FreeIPA
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install \
  freeipa-server
