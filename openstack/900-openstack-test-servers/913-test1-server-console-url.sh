#!/bin/bash

##############################################################################
# Get URL for connecting to server instance on Controller host
##############################################################################
openstack console url show \
  test1_dmz
openstack console url show \
  test1_servers
openstack console url show \
  test1_inside
