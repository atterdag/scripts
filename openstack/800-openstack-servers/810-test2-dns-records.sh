#!/bin/sh

##############################################################################
# Create a fixed IP ports
##############################################################################
openstack port create \
  --fixed-ip ip-address=192.168.1.130 \
  --network default \
  test2_inside
openstack port create \
  --fixed-ip ip-address=172.16.0.130 \
  --network servers \
  test2_servers
openstack port create \
  --fixed-ip ip-address=10.0.0.130 \
  --network dmz \
  test2_dmz
