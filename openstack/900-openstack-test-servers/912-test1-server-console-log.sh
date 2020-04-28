#!/bin/bash

##############################################################################
# Get URL for connecting to server instance on Controller host
##############################################################################
openstack console log show \
  test1_dmz
openstack console log show \
  test1_servers
openstack console log show \
  test1_inside
