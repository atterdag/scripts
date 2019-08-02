#!/bin/bash

##############################################################################
# Create volume template on Controller host
##############################################################################
openstack volume create \
  --description 'debian-10-openstack-amd64 template volume' \
  --image debian-10-openstack-amd64 \
  --size 10 \
  --type standard \
  debian-10-openstack-amd64
