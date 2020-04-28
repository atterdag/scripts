9#!/bin/bash

openstack server create \
  --flavor m1.tiny \
  --image cirros-0.5.1 \
  --key-name default \
  --nic port-id=test2_servers \
  --security-group global_default \
  --wait \
  test2_servers
openstack server create \
  --flavor m1.tiny \
  --image cirros-0.5.1 \
  --key-name default \
  --nic port-id=test2_dmz \
  --security-group global_default \
  --wait \
  test2_dmz
openstack server create \
  --flavor m1.tiny \
  --image cirros-0.5.1 \
  --key-name default \
  --nic port-id=test2_inside \
  --security-group global_default \
  --wait \
  test2_inside
