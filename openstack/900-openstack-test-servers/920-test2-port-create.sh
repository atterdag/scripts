#!/bin/bash

openstack port create \
  --fixed-ip ip-address=172.16.0.202 \
  --network servers \
  --security-group global_default \
  test2_servers
openstack port create \
  --fixed-ip ip-address=10.0.0.202 \
  --network dmz \
  --security-group global_default \
  test2_dmz
