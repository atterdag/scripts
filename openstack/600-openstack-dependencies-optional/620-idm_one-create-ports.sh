#!/bin/bash

##############################################################################
# Create a fixed IP ports
##############################################################################
if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  openstack port create \
    --fixed-ip ip-address=${IDM_ONE_IP_ADDRESS} \
    --network servers \
    ${IDM_ONE_HOST_NAME}
fi
