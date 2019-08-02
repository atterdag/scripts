#!/bin/bash

##############################################################################
# Install Cinder on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  cinder-api \
  cinder-scheduler
