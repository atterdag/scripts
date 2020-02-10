#!/bin/bash

##############################################################################
# Test that Plcement have been registerd on Controller host
##############################################################################
placement-status upgrade check
openstack --os-placement-api-version 1.2 resource class list --sort-column name
openstack --os-placement-api-version 1.6 trait list --sort-column name
