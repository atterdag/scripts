#!/bin/bash

##############################################################################
# Create debian server instance on Controller host
##############################################################################
openstack server create \
  --flavor m1.medium \
  --image debian-10-openstack-amd64 \
  --key-name default \
  --nic port-id=${NS_HOST_NAME} \
  --security-group default \
  ${NS_HOST_NAME}
