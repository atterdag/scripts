#!/bin/bash
openstack floating ip create \
  --floating-ip-address 192.168.254.88 \
  --description "Kubernetes Master Node" \
  --tag kubernetes \
  routing

openstack server add floating ip \
  k8s_master01 \
  192.168.254.88

ping \
  -c 4 \
  192.168.254.88
