#!/bin/bash

##############################################################################
# Check Designate Services are registered on Controller host
##############################################################################
openstack dns service list

##############################################################################
# Add dns extension to neutron
##############################################################################
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers "port_security,dns"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT dns_domain "servers.${DNS_DOMAIN}."
sudo systemctl restart \
  nova-api \
  neutron-server \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent
