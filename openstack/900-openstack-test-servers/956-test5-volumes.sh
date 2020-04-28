#!/bin/bash

##############################################################################
# Create volumes on Controller host
##############################################################################
openstack volume create \
  --description 'test5 database volume' \
  --size 10 \
  --type premium \
  test5_database

openstack server add volume \
  test5 \
  test5_database

openstack volume create \
  --description 'test5 files volume' \
  --size 10 \
  --type standard \
  test5_files

openstack server add volume \
  test5 \
  test5_files
