#!/bin/bash

##############################################################################
# List prerequisite resources for creating a server instance on Controller host
##############################################################################
openstack keypair list
openstack flavor list
openstack image list
openstack network list
openstack subnet list
openstack security group list
openstack port list
openstack volume type list
openstack volume list
