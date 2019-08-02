#!/bin/bash

##############################################################################
# Check Neutron on Controller host
##############################################################################
sudo -E neutron ext-list
openstack network agent list
