#!/bin/bash

##############################################################################
# Register Designate on Controller host
##############################################################################
if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  if ! grep ${NS_FQDN} /etc/hosts > /dev/null; then
    echo -e "${NS_IP_ADDRESS}\t${NS_FQDN}\t${NS_HOST_NAME}" \
    |  sudo tee -a /etc/hosts
  fi
fi
if [[ $CONTROLLER_FQDN != $NSS_FQDN ]]; then
  if ! grep ${NSS_FQDN} /etc/hosts > /dev/null; then
    echo -e "${NSS_IP_ADDRESS}\t${NSS_FQDN}\t${NSS_HOST_NAME}" \
    | sudo tee -a /etc/hosts
  fi
fi

openstack user create \
  --domain default \
  --password $DESIGNATE_PASS \
  designate
openstack role add \
  --project service \
  --user designate \
  admin
openstack service create \
  --name designate \
  --description 'OpenStack DNS' \
  dns
openstack endpoint create \
  --region RegionOne \
  dns public http://${NS_FQDN}:9001/
