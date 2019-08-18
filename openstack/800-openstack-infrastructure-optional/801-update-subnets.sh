#!/bin/bash

##############################################################################
# Create subnets for VLANs on Controller host
##############################################################################
# openstack subnet set \
#   --dns-nameserver ${NS_IP_ADDRESS} \
#   --dns-nameserver ${NSS_IP_ADDRESS} \
#   inside
openstack subnet set \
  --dns-nameserver ${NS_IP_ADDRESS} \
  --dns-nameserver ${NSS_IP_ADDRESS} \
  servers
openstack subnet set \
  --dns-nameserver ${NS_IP_ADDRESS} \
  --dns-nameserver ${NSS_IP_ADDRESS} \
  dmz
