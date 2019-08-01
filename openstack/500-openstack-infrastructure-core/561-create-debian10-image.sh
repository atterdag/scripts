#!/bin/sh

##############################################################################
# Create debian-stretch-amd64 image on Controller host
##############################################################################
# Ref https://docs.openstack.org/image-guide/obtain-images.html
sudo wget \
  --continue \
  --output-document=/var/lib/openstack/debian-10-openstack-amd64.qcow2 \
  http://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.qcow2

sudo -E openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file /var/lib/openstack/debian-10-openstack-amd64.qcow2 \
  --public \
  debian-10-openstack-amd64
