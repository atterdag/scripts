#!/bin/sh

##############################################################################
# Create volume template on Controller host
##############################################################################
openstack volume create \
  --description 'debian-9-openstack-amd64 template volume' \
  --image debian-9-openstack-amd64 \
  --size 5 \
  --type standard \
  debian-9-openstack-amd64
