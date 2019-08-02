#!/bin/bash

##############################################################################
# Create volumes on Controller host
##############################################################################
openstack volume create \
  --description 'test2 database volume' \
  --size 10 \
  --type premium \
  test2_database
openstack server add volume \
  test2 \
  test2_database

openstack volume create \
--description 'test2 files volume' \
--size 10 \
--type standard \
test2_files
openstack server add volume \
  test2 \
  test2_files
