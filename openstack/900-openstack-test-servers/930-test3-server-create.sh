#!/bin/bash

openstack server create \
  --flavor m1.medium \
  --image ubuntu-18.04-server-cloudimg-amd64 \
  --key-name default \
  --nic net-id=servers \
  --security-group global_default \
  --wait \
  test3_servers
openstack server create \
  --flavor m1.medium \
  --image ubuntu-18.04-server-cloudimg-amd64 \
  --key-name default \
  --nic net-id=dmz \
  --security-group global_default \
  --wait \
  test3_dmz
openstack server create \
  --flavor m1.medium \
  --image ubuntu-18.04-server-cloudimg-amd64 \
  --key-name default \
  --nic net-id=inside \
  --security-group global_default \
  --wait \
  test3_inside
