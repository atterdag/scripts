#!/bin/sh

##############################################################################
# Attach ports with fixed IP to existing server instance on Controller host
##############################################################################
export $(openstack port show test2_dmz -f shell -c id | sed 's|"||g')
nova interface-attach \
  --port-id $id \
  test2
