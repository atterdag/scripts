#!/bin/bash

##############################################################################
# Create a fixed IP ports
##############################################################################
openstack port create \
  --enable-port-security \
  --network inside \
  --no-fixed-ip \
  --security-group dhcp_client \
  --security-group global_default \
  test5_inside
openstack port create \
  --fixed-ip ip-address=172.16.0.205 \
  --network servers \
  --security-group global_default \
  test5_servers
openstack port create \
  --fixed-ip ip-address=10.0.0.205 \
  --network dmz \
  --security-group global_default \
  test5_dmz
