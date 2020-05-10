#!/bin/bash

# How to connect to non routable vxlan server with floating ip address
openstack network create \
  --internal \
  --tag testfloat \
  testfloat

openstack subnet create \
  --allocation-pool start=192.168.12.129,end=192.168.12.196 \
  --dns-nameserver ${DNS_ONE_IP_ADDRESS} \
  --dns-nameserver ${DNS_TWO_IP_ADDRESS} \
  --gateway 192.168.12.254 \
  --network testfloat \
  --subnet-range 192.168.12.0/24 \
  --tag testfloat \
  testfloat

openstack router create \
  --tag testfloat \
  testfloat

openstack router add subnet \
  testfloat \
  testfloat

openstack router set \
  --external-gateway routing \
  --fixed-ip subnet=routing,ip-address=192.168.254.12 \
  testfloat

openstack server create \
  --flavor m1.tiny \
  --image cirros-0.5.1 \
  --key-name default \
  --nic net-id=testfloat \
  --security-group global_default \
  --wait \
  testfloat

openstack floating ip create \
  --floating-ip-address 192.168.254.122 \
  --description testfloat \
  --tag testfloat \
  routing

openstack server add floating ip \
  testfloat \
  192.168.254.122

ping \
  -c 4 \
  192.168.254.122
