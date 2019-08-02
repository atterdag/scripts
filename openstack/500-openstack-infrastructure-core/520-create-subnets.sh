#!/bin/bash

##############################################################################
# Create subnets for VLANs on Controller host
##############################################################################
openstack subnet create \
  --allocation-pool start=192.168.1.129,end=192.168.1.196 \
  --dns-nameserver ${CONTROLLER_IP_ADDRESS} \
  --gateway 192.168.1.254 \
  --ip-version 4 \
  --network default \
  --no-dhcp \
  --subnet-range 192.168.1.0/24 \
  default
openstack subnet create \
  --allocation-pool start=172.16.0.2,end=172.16.0.253 \
  --dhcp \
  --dns-nameserver ${CONTROLLER_IP_ADDRESS} \
  --gateway 172.16.0.254 \
  --ip-version 4 \
  --network servers \
  --subnet-range 172.16.0.0/24 \
  servers
openstack subnet create \
  --allocation-pool start=10.0.0.2,end=10.0.0.253 \
  --dns-nameserver ${CONTROLLER_IP_ADDRESS} \
  --gateway 10.0.0.254 \
  --ip-version 4 \
  --network dmz \
  --no-dhcp \
  --subnet-range 10.0.0.0/24 \
  dmz
