#!/bin/bash

##############################################################################
# Create default security on Controller host
##############################################################################
# The default group is created for all projects, but that means that you
# cannot just refer to it by its name, because there are multiple default
# groups. So to workaround that, just create a global default group that will
# have a unique name.
openstack security group create \
  --description "Global default rule" \
  global_default
openstack security group rule create \
  --ingress \
  --ethertype IPv4 \
  --remote-ip "0.0.0.0/0" \
  global_default
openstack security group rule create \
  --ingress \
  --ethertype IPv6 \
  --remote-ip "::/0" \
  global_default
openstack security group rule create \
  --proto icmp \
  global_default
openstack security group rule create \
  --proto tcp \
  --dst-port 22 \
  global_default

openstack security group create \
  --description "DHCP client" \
  dhcp_client
openstack security group rule create \
  --egress \
  --ethertype IPv4 \
  --remote-ip "0.0.0.0/0" \
  --proto udp \
  --dst-port 67 \
  dhcp_client
openstack security group rule create \
  --ingress \
  --ethertype IPv4 \
  --remote-ip "0.0.0.0/0" \
  --proto udp \
  --dst-port 68 \
  dhcp_client
