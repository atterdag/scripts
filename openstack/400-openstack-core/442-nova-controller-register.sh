#!/bin/bash

##############################################################################
# Register Nova on Controller host
##############################################################################
openstack user create \
  --domain default \
  --password $NOVA_PASS \
  nova
openstack role add \
  --project service \
  --user nova \
  admin
openstack service create \
  --name nova \
  --description "OpenStack Compute" \
  compute
openstack endpoint create \
  --region RegionOne \
  compute public http://${CONTROLLER_FQDN}:8774/v2.1
openstack endpoint create \
  --region RegionOne \
  compute internal http://${CONTROLLER_FQDN}:8774/v2.1
openstack endpoint create \
  --region RegionOne \
  compute admin http://${CONTROLLER_FQDN}:8774/v2.1
