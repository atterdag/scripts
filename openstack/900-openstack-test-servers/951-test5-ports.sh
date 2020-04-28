#!/bin/bash

##############################################################################
# Create a fixed IP ports
##############################################################################
openstack port create \
  --fixed-ip ip-address=192.168.1.205 \
  --network inside \
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
