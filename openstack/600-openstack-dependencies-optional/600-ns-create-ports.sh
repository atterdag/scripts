#!/bin/sh

##############################################################################
# Create a fixed IP ports
##############################################################################
openstack port create \
  --fixed-ip ip-address=${NS_IP_ADDRESS} \
  --network default \
  ${NS_HOST_NAME}
