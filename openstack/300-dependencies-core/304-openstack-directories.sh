#!/bin/bash

##############################################################################
# Create directory to store openstack files
##############################################################################
sudo mkdir -p ${OS_CONFIGURATION_DIRECTORY}/
sudo chown root:root ${OS_CONFIGURATION_DIRECTORY}/
sudo chmod 0700 ${OS_CONFIGURATION_DIRECTORY}/
