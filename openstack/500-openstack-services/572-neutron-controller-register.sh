#!/bin/sh

##############################################################################
# Register Neutron services on Controller host
##############################################################################
openstack user create \
  --domain default \
  --password $NEUTRON_PASS \
  neutron
openstack role add \
  --project service \
  --user neutron \
  admin
openstack service create \
  --name neutron \
  --description 'OpenStack Networking' \
  network
openstack endpoint create \
  --region RegionOne \
  network public http://${CONTROLLER_FQDN}:9696
openstack endpoint create \
  --region RegionOne \
  network internal http://${CONTROLLER_FQDN}:9696
openstack endpoint create \
  --region RegionOne \
  network admin http://${CONTROLLER_FQDN}:9696
