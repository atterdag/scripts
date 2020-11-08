#!/bin/bash

openstack port create \
  --disable-port-security \
  --network outside \
  --no-fixed-ip \
  firewall_outside

openstack port create \
  --fixed-ip ip-address=10.0.0.254 \
  --network dmz \
  --security-group global_default \
  firewall_dmz

openstack port create \
  --disable-port-security \
  --network inside \
  --no-fixed-ip \
  firewall_inside

openstack server create \
  --flavor m1.medium \
  --image pfSense-CE-memstick-2.4.5-RELEASE-amd64 \
  --key-name default \
  --nic port-id=firewall_dmz \
  --wait \
  firewall

openstack server add port \
  firewall \
  firewall_inside

openstack server add port \
  firewall \
  firewall_outside

openstack console url show \
  firewall
