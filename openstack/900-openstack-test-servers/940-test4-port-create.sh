#!/bin/bash

openstack port create \
  --fixed-ip ip-address=192.168.1.204 \
  --network inside \
  --security-group global_default \
  test4_inside
openstack port create \
  --fixed-ip ip-address=172.16.0.204 \
  --network servers \
  --security-group global_default \
  test4_servers
openstack port create \
  --fixed-ip ip-address=10.0.0.204 \
  --network dmz \
  --security-group global_default \
  test4_dmz
