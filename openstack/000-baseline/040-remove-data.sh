#!/bin/bash

##############################################################################
# Remove OpenStack data
##############################################################################
sudo rm -fr \
  ${OPENSTACK_CONFIGURATION_DIRECTORY}/ \
  /var/lib/ssl/ \
  /root/.dogtag
