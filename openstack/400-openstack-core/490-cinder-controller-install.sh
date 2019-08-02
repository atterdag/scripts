#!/bin/bash

##############################################################################
# Install Cinder on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  cinder-api \
  cinder-scheduler
