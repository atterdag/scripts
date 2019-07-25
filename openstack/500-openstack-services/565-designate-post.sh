#!/bin/sh
##############################################################################
# Check Designate Services are registered on Controller host
##############################################################################
openstack dns service list

##############################################################################
# Create DNS zones, and records for controller
##############################################################################
echo openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  ${DNS_DOMAIN}.
echo openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  ${DNS_REVERSE_DOMAIN}.
echo openstack recordset create \
  --record "${CONTROLLER_IP_ADDRESS}" \
  --type A ${DNS_DOMAIN}. \
  $(echo $CONTROLLER_FQDN | awk -F'.' '{print $1}')
echo openstack recordset create \
  --record "${CONTROLLER_FQDN}." \
  --type PTR ${DNS_REVERSE_DOMAIN}. \
  $(echo $CONTROLLER_IP_ADDRESS | awk -F'.' '{print $4}')
