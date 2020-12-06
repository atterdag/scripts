#!/bin/bash

##############################################################################
# Create a fixed IP ports
##############################################################################
if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  openstack port create \
    --fixed-ip ip-address=${NS_IP_ADDRESS} \
    --network servers \
    --security-group default \
    --security-group designate \
    --security-group domain \
    --security-group domain_xfer \
    --security-group rndc \
    ${NS_HOST_NAME}
fi
# openstack port create \
#   --fixed-ip ip-address=${NS_IP_ADDRESS} \
#   --network servers \
#   --security-group default \
#   --security-group designate \
#   --security-group domain \
#   --security-group domain_xfer \
#   --security-group rndc \
#   --dns-domain "${ROOT_DNS_DOMAIN}" \
#   --dns-name "${NS_HOST_NAME}" \
#   ${NS_HOST_NAME}
