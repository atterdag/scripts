#!/bin/bash

##############################################################################
# Create debian server instance on Controller host
##############################################################################
openstack server create \
  --flavor m1.medium \
  --image ubuntu-18.04-server-cloudimg-amd64 \
  --key-name default \
  --nic port-id=test5_dmz \
  --nic port-id=test5_inside \
  --security-group global_default \
  --wait \
  test5
