#!/bin/bash

##############################################################################
# Install OpenStack command line tool on Controller host
##############################################################################
sudo apt-get --yes --quiet install \
  python3-openstackclient \
  python3-oslo.log
