#!/bin/bash

##############################################################################
# List prerequisite services for creating a server instance on Controller host
##############################################################################
for service in keypair flavor image network subnet "security group" port "volume type" volume; do
  echo "--- $service ---"
  openstack $service list
done
