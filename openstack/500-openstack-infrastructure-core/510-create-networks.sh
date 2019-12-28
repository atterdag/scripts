#!/bin/bash

##############################################################################
# Create VLAN network on Controller host
##############################################################################
openstack network create \
  --enable \
  --enable-port-security \
  --internal \
  --provider-network-type vlan \
  --provider-physical-network ${NETWORK_INTERFACE} \
  --provider-segment 2 \
  --share \
  autovoip
openstack network create \
  --enable \
  --enable-port-security \
  --internal \
  --provider-network-type vlan \
  --provider-physical-network ${NETWORK_INTERFACE} \
  --provider-segment 3 \
  --share \
  autovideo
openstack network create \
  --enable \
  --enable-port-security \
  --external \
  --provider-network-type vlan \
  --provider-physical-network ${NETWORK_INTERFACE} \
  --provider-segment 4 \
  --share \
  inside
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
  --provider-segment 7 \
  --share \
  outside
