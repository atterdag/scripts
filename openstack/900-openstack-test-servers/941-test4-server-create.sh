#!/bin/bash

openstack server create \
  --flavor m1.medium \
  --image ubuntu-18.04-server-cloudimg-amd64 \
  --key-name default \
  --nic port-id=test4_servers \
  --security-group global_default \
  --wait \
  test4_servers
openstack server create \
  --flavor m1.medium \
  --image ubuntu-18.04-server-cloudimg-amd64 \
  --key-name default \
  --nic port-id=test4_dmz \
  --security-group global_default \
  --wait \
  test4_dmz
openstack server create \
  --flavor m1.medium \
  --image ubuntu-18.04-server-cloudimg-amd64 \
  --key-name default \
  --nic port-id=test4_inside \
  --security-group global_default \
  --wait \
  test4_inside
