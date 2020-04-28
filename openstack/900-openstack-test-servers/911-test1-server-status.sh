#!/bin/bash

##############################################################################
# Show server status
##############################################################################
openstack server show \
  test1_dmz
openstack server show \
  test1_servers
openstack server show \
  test1_inside
