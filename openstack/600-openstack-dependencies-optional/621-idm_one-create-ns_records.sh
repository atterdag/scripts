#!/bin/bash

##############################################################################
# Create a fixed IP ports
##############################################################################
openstack port create \
  --fixed-ip ip-address=${IDM_ONE_IP_ADDRESS} \
  --network default \
  ${IDM_ONE_HOST_NAME}
