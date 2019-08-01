#!/bin/sh

##############################################################################
# Register Cinder services on Controller host
##############################################################################
openstack user create \
  --domain default \
  --password $CINDER_PASS \
  cinder
openstack role add \
  --project service \
  --user cinder \
  admin

openstack service create \
  --name cinder \
  --description 'OpenStack Block Storage' \
  volume
openstack service create \
  --name cinderv2 \
  --description 'OpenStack Block Storage' \
  volumev2
openstack service create \
  --name cinderv3 \
  --description 'OpenStack Block Storage' \
  volumev3

openstack endpoint create \
  --region RegionOne \
  volume public http://${CONTROLLER_FQDN}:8776/v1/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volume internal http://${CONTROLLER_FQDN}:8776/v1/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volume admin http://${CONTROLLER_FQDN}:8776/v1/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 public http://${CONTROLLER_FQDN}:8776/v2/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 internal http://${CONTROLLER_FQDN}:8776/v2/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 admin http://${CONTROLLER_FQDN}:8776/v2/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev3 public http://${CONTROLLER_FQDN}:8776/v3/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev3 internal http://${CONTROLLER_FQDN}:8776/v3/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev3 admin http://${CONTROLLER_FQDN}:8776/v3/%\(project_id\)s
