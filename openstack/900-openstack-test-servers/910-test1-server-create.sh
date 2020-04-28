#!/bin/bash

##############################################################################
# Create debian server instance on Controller host
##############################################################################
openstack server create \
  --flavor m1.tiny \
  --image cirros-0.5.1 \
  --key-name default \
  --nic net-id=dmz \
  --security-group global_default \
  --wait \
  test1_dmz
openstack server create \
  --flavor m1.tiny \
  --image cirros-0.5.1 \
  --key-name default \
  --nic net-id=servers \
  --security-group global_default \
  --wait \
  test1_servers
openstack server create \
  --flavor m1.tiny \
  --image cirros-0.5.1 \
  --key-name default \
  --nic net-id=inside \
  --security-group global_default \
  --wait \
  test1_inside
