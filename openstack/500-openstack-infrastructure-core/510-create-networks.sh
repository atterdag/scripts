#!/bin/bash

##############################################################################
# Create VLAN network on Controller host
##############################################################################
openstack network create \
  --enable \
  --enable-port-security \
  --external \
  --provider-network-type vlan \
  --provider-physical-network ${NETWORK_INTERFACE} \
  --provider-segment 1 \
  --share \
  default
openstack network create \
  --enable \
  --enable-port-security \
  --internal \
  --provider-network-type vlan \
  --provider-physical-network ${NETWORK_INTERFACE} \
  --provider-segment 5 \
  --share \
  servers
openstack network create \
  --enable \
  --enable-port-security \
  --internal \
  --provider-network-type vlan \
  --provider-physical-network ${NETWORK_INTERFACE} \
  --provider-segment 6 \
  --share \
  dmz
openstack network create \
  --enable \
  --enable-port-security \
  --external \
  --provider-network-type vlan \
  --provider-physical-network ${NETWORK_INTERFACE} \
  --provider-segment 4 \
  --share \
  outside
