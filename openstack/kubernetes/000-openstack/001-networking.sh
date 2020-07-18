#!/bin/bash

openstack network create \
  --internal \
  --tag kubernetes \
  k8s_network

openstack subnet create \
  --allocation-pool start=192.168.8.1,end=192.168.8.253 \
  --dns-nameserver 192.168.1.3 \
  --dns-nameserver 192.168.1.4 \
  --gateway 192.168.8.254 \
  --network k8s_network \
  --subnet-range 192.168.8.0/24 \
  --tag kubernetes \
  k8s_subnet

openstack router create \
  --tag kubernetes \
  k8s_router

openstack router add subnet \
  k8s_router \
  k8s_subnet

openstack router set \
  --external-gateway routing \
  --fixed-ip subnet=routing,ip-address=192.168.254.8 \
  k8s_router
