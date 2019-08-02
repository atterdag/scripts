#!/bin/bash

##############################################################################
# Install Barbican on Controller host
##############################################################################
openstack user create \
  --domain default \
  --password $BARBICAN_PASS \
  barbican
openstack role add \
  --project service \
  --user barbican \
  admin
openstack role create \
  creator
openstack role add \
  --project service \
  --user barbican \
  creator
openstack service create \
  --name barbican \
  --description "Key Manager" \
  key-manager
openstack endpoint create \
  --region RegionOne \
  key-manager public http://${CONTROLLER_FQDN}:9311
openstack endpoint create \
  --region RegionOne \
  key-manager internal http://${CONTROLLER_FQDN}:9311
openstack endpoint create \
  --region RegionOne \
  key-manager admin http://${CONTROLLER_FQDN}:9311
