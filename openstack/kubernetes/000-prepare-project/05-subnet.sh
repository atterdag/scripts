#!/bin/bash

openstack subnet create \
  --allocation-pool start=192.168.8.1,end=192.168.8.253 \
  --dns-nameserver 192.168.1.3 \
  --dns-nameserver 192.168.1.4 \
  --gateway 192.168.8.254 \
  --network k8s_network \
  --subnet-range 192.168.8.0/24 \
  --project k8s_project \
  --tag kubernetes \
  k8s_subnet
