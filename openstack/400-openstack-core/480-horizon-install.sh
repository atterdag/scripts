#!/bin/bash

##############################################################################
# Install Horizon on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  openstack-dashboard
