#!/bin/bash

##############################################################################
# Create DNZ records for test2
##############################################################################
openstack recordset create \
  --record '192.168.1.130' \
  --type A ${DNS_DOMAIN}. \
  test2
openstack recordset create \
  --record 'test2.se.lemche.net.' \
  --type PTR 1.168.192.in-addr.arpa. \
  130

openstack recordset create \
  --record '172.16.0.130' \
  --type A servers.${DNS_DOMAIN}. \
  test2
openstack recordset create \
  --record 'test2.servers.se.lemche.net.' \
  --type PTR 0.16.172.in-addr.arpa. \
  130

openstack recordset create \
  --record '10.0.0.130' \
  --type A dmz.${DNS_DOMAIN}. \
  test2
openstack recordset create \
  --record 'test2.dmz.se.lemche.net.' \
  --type PTR 0.0.10.in-addr.arpa. \
  130
