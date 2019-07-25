#!/bin/sh

##############################################################################
# Register Glance service on Controller host
##############################################################################
openstack user create \
  --domain default \
  --password $GLANCE_PASS \
  glance
openstack role add \
  --project service \
  --user glance \
  admin
openstack service create \
  --name glance \
  --description 'OpenStack Image' \
  image
openstack endpoint create \
  --region RegionOne \
  image public http://${CONTROLLER_FQDN}:9292
openstack endpoint create \
  --region RegionOne \
  image internal http://${CONTROLLER_FQDN}:9292
openstack endpoint create \
  --region RegionOne \
  image admin http://${CONTROLLER_FQDN}:9292
