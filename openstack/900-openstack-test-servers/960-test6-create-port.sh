#!/bin/bash

openstack port create \
  --network outside \
  --disable-port-security \
  test6_outside

openstack server create \
  --flavor m1.tiny \
  --image cirros-0.5.1 \
  --key-name default \
  --nic port-id=test6_outside \
  --wait \
  test6_outside
