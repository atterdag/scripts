#!/bin/bash

##############################################################################
# Create debian server instance on Controller host
##############################################################################
openstack server create \
  --flavor m1.medium \
  --image debian-9-openstack-amd64 \
  --key-name default \
  --nic port-id=test2_inside \
  --nic port-id=test2_servers \
  --security-group default \
  test2
