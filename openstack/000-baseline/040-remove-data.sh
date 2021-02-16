#!/bin/bash

##############################################################################
# Remove OpenStack data
##############################################################################
sudo rm -fr \
  ${OS_CONFIGURATION_DIRECTORY}/ \
  /var/lib/ssl/ \
  /root/.dogtag
