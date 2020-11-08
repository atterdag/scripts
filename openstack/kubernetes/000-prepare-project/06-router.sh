#!/bin/bash

openstack router create \
  --tag kubernetes \
  --project k8s_project \
  k8s_router

openstack router add subnet \
  k8s_router \
  k8s_subnet

openstack router set \
  --external-gateway routing \
  --fixed-ip subnet=routing,ip-address=192.168.254.8 \
  k8s_router
