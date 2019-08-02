#!/bin/bash

##############################################################################
# Check Cinder on Compute host
##############################################################################
openstack volume service list

openstack volume type create \
  --property volume_backend_name='premium' \
  premium

openstack volume type create \
  --property volume_backend_name='standard' \
  standard
