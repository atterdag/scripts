#!/bin/sh

##############################################################################
# Create debian server instance on Controller host
##############################################################################
openstack server create \
  --flavor m1.medium \
  --image debian-10-openstack-amd64 \
  --key-name default \
  --nic port-id=ns \
  --security-group default \
  ns
