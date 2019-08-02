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
openstack zone list
openstack recordset list ${DNS_DOMAIN}.
openstack recordset list 1.168.192.in-addr.arpa.
openstack recordset list servers.${DNS_DOMAIN}.
openstack recordset list 0.16.172.in-addr.arpa.
openstack recordset list dmz.${DNS_DOMAIN}.
openstack recordset list 0.0.10.in-addr.arpa.
openstack volume type list
openstack volume list
