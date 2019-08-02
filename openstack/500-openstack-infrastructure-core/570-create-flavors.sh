#!/bin/bash

##############################################################################
# Create flavors on Controller host
##############################################################################
openstack flavor create \
  --disk 1 \
  --public \
  --ram 56 \
  --vcpus 1 \
  m1.tiny
openstack flavor create \
  --disk 1 \
  --public \
  --ram 128 \
  --vcpus 1 \
  m1.small
openstack flavor create \
  --disk 5 \
  --public \
  --ram 256 \
  --vcpus 1 \
  m1.medium
openstack flavor create \
  --disk 10 \
  --public \
  --ram 512 \
  --vcpus 1 \
  m1.large
openstack flavor create \
  --disk 10 \
  --public \
  --ram 1024 \
  --vcpus 2 \
  m1.huge
