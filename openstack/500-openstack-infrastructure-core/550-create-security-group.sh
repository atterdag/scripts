#!/bin/bash

##############################################################################
# Create default security on Controller host
##############################################################################
openstack security group rule create \
  --proto icmp \
  default
openstack security group rule create \
  --proto tcp \
  --dst-port 22 \
  default
