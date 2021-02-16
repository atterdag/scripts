#!/bin/bash

##############################################################################
# Create DNS zones for additional subnets
##############################################################################
openstack zone create \
  --email hostmaster@${ROOT_DNS_DOMAIN} \
  servers.${ROOT_DNS_DOMAIN}.
openstack zone create \
  --email hostmaster@${ROOT_DNS_DOMAIN} \
  0.16.172.in-addr.arpa.

openstack zone create \
  --email hostmaster@os.${ROOT_DNS_DOMAIN} \
  os.${ROOT_DNS_DOMAIN}.
openstack zone create \
  --email hostmaster@${ROOT_DNS_DOMAIN} \
  0.16.172.in-addr.arpa.

openstack zone create \
  --email hostmaster@${ROOT_DNS_DOMAIN} \
  dmz.${ROOT_DNS_DOMAIN}.
openstack zone create \
  --email hostmaster@${ROOT_DNS_DOMAIN} \
  0.0.10.in-addr.arpa.

# ##############################################################################
# # Create DNS zones, and records for controller
# ##############################################################################
# openstack zone create \
#   --email hostmaster@${ROOT_DNS_DOMAIN} \
#   --masters 192.168.0.40 \
#   --type secondary  \
#   ${ROOT_DNS_DOMAIN}.
# openstack zone create \
#   --email hostmaster@${ROOT_DNS_DOMAIN} \
#   --masters 192.168.0.40 \
#   --type secondary  \
#   ${DNS_REVERSE_DOMAIN}.
# openstack recordset create \
#   --record "${OS_CONTROLLER_IP_ADDRESS}" \
#   --type A ${ROOT_DNS_DOMAIN}. \
#   ${OS_CONTROLLER_HOST_NAME}
# openstack recordset create \
#   --record "${CONTROLLER_FQDN}." \
#   --type PTR ${DNS_REVERSE_DOMAIN}. \
#   $(echo $OS_CONTROLLER_IP_ADDRESS | awk -F'.' '{print $4}')
#
# ##############################################################################
# # Create DNZ records for ns
# ##############################################################################
# openstack recordset create \
#   --record ${NS_IP_ADDRESS} \
#   --type A ${ROOT_DNS_DOMAIN}. \
#   ${NS_HOST_NAME}
# openstack recordset create \
#   --record "${NS_FQDN}." \
#   --type PTR ${DNS_REVERSE_DOMAIN}. \
#   $(echo $NS_IP_ADDRESS | awk -F'.' '{print $4}')
