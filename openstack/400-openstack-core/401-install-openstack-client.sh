#!/bin/bash

##############################################################################
# Install OpenStack command line tool on Controller host
##############################################################################
sudo apt-get --yes --quiet install \
  python-openstackclient \
  python-oslo.log
