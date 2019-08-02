#!/bin/bash

##############################################################################
# Install OpenStack command line tool on Controller host
##############################################################################
sudo apt-get --yes install \
  python-openstackclient \
  python-oslo.log
