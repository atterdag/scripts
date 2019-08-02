#!/bin/bash

##############################################################################
# Create DNS zones for additional subnets
##############################################################################
openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  servers.${DNS_DOMAIN}.
openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  0.16.172.in-addr.arpa.

openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  dmz.${DNS_DOMAIN}.
openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  0.0.10.in-addr.arpa.
