#!/bin/bash

##############################################################################
# Create volume template on Controller host
##############################################################################
openstack volume create \
  --description 'ubuntu-18.04-server-cloudimg-amd64 template volume' \
  --image ubuntu-18.04-server-cloudimg-amd64 \
  --size 10 \
  --type standard \
  ubuntu-18.04-server-cloudimg-amd64
