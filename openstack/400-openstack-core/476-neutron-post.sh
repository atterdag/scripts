#!/bin/bash

##############################################################################
# Check Neutron on Controller host
##############################################################################
sudo --preserve-env neutron ext-list
openstack network agent list
