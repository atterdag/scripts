#!/bin/bash

##############################################################################
# Create volume template on Controller host
##############################################################################
openstack volume create \
  --description 'CentOS-7-x86_64-GenericCloud template volume' \
  --image CentOS-7-x86_64-GenericCloud \
  --size 10 \
  --type standard \
  CentOS-7-x86_64-GenericCloud
