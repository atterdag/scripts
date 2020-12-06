#!/bin/bash

##############################################################################
# List prerequisite resources for creating a server instance on Controller host
##############################################################################
openstack zone list
openstack recordset list ${OS_DNS_DOMAIN}.
openstack recordset list 1.168.192.in-addr.arpa.
openstack recordset list servers.${ROOT_DNS_DOMAIN}.
openstack recordset list 0.16.172.in-addr.arpa.
openstack recordset list dmz.${ROOT_DNS_DOMAIN}.
openstack recordset list 0.0.10.in-addr.arpa.
