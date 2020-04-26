#!/bin/bash

##############################################################################
# Create flavors on Controller host
##############################################################################
openstack flavor create \
  --disk 1 \
  --public \
  --ram 128 \
  --vcpus 1 \
  --property hw:cpu_policy=shared \
  --property hw:cpu_cores=1 \
  --property hw:cpu_sockets=1 \
  --property hw:cpu_threads=1 \
  m1.tiny
openstack flavor create \
  --disk 5 \
  --public \
  --ram 256 \
  --vcpus 1 \
  --property hw:cpu_policy=shared \
  m1.small
openstack flavor create \
  --disk 5 \
  --public \
  --ram 512 \
  --vcpus 2 \
  --property hw:cpu_policy=shared \
  m1.medium
openstack flavor create \
  --disk 5 \
  --public \
  --ram 1024 \
  --vcpus 2 \
  --property hw:cpu_policy=shared \
  m1.large
openstack flavor create \
  --disk 5 \
  --public \
  --ram 2048 \
  --vcpus 4 \
  --property hw:cpu_policy=shared \
  m1.huge
