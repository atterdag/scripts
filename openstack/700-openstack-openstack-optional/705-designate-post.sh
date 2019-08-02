#!/bin/bash

##############################################################################
# Check Designate Services are registered on Controller host
##############################################################################
openstack dns service list

##############################################################################
# Add dns extension to neutron
##############################################################################
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers "port_security,dns"
sudo systemctl restart \
  nova-api \
  neutron-server \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent

##############################################################################
# Create DNS zones, and records for controller
##############################################################################
openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  ${DNS_DOMAIN}.
openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  ${DNS_REVERSE_DOMAIN}.
openstack recordset create \
  --record "${CONTROLLER_IP_ADDRESS}" \
  --type A ${DNS_DOMAIN}. \
  ${CONTROLLER_HOST_NAME}
openstack recordset create \
  --record "${CONTROLLER_FQDN}." \
  --type PTR ${DNS_REVERSE_DOMAIN}. \
  $(echo $CONTROLLER_IP_ADDRESS | awk -F'.' '{print $4}')

##############################################################################
# Create DNZ records for ns
##############################################################################
openstack recordset create \
  --record ${NS_IP_ADDRESS} \
  --type A ${DNS_DOMAIN}. \
  ${NS_HOST_NAME}
openstack recordset create \
  --record "${NS_FQDN}." \
  --type PTR ${DNS_REVERSE_DOMAIN}. \
  $(echo $NS_IP_ADDRESS | awk -F'.' '{print $4}')
