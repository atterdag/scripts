#!/bin/sh

##############################################################################
# Register Designate on Controller host
##############################################################################
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
  dns public http://${CONTROLLER_FQDN}:9001/
