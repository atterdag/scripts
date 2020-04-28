#!/bin/bash

##############################################################################
# Create DNZ records for test5
##############################################################################
openstack recordset create \
  --record '192.168.0.205' \
  --type A ${DNS_DOMAIN}. \
  test5
openstack recordset create \
  --record 'test5.se.lemche.net.' \
  --type PTR 1.168.192.in-addr.arpa. \
  205

openstack recordset create \
  --record '172.16.0.205' \
  --type A servers.${DNS_DOMAIN}. \
  test5
openstack recordset create \
  --record 'test5.servers.se.lemche.net.' \
  --type PTR 0.16.172.in-addr.arpa. \
  205

openstack recordset create \
  --record '10.0.0.205' \
  --type A dmz.${DNS_DOMAIN}. \
  test5
openstack recordset create \
  --record 'test5.dmz.se.lemche.net.' \
  --type PTR 0.0.10.in-addr.arpa. \
  205
