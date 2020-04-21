#!/bin/bash

##############################################################################
# Create directory to store openstack files
##############################################################################
sudo mkdir -p ${OPENSTACK_CONFIGURATION_DIRECTORY}/
sudo chown root:root ${OPENSTACK_CONFIGURATION_DIRECTORY}/
sudo chmod 0700 ${OPENSTACK_CONFIGURATION_DIRECTORY}/
