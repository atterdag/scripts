#!/bin/bash

##############################################################################
# Create debian server instance on Controller host
##############################################################################
openstack server create \
  --flavor m1.small \
  --image cirros-0.4.0 \
  --key-name default \
  --nic net-id=dmz \
  --security-group default \
  test1
