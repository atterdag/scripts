#!/bin/bash

##############################################################################
# Create debian-stretch-amd64 image on Controller host
##############################################################################
# Ref https://docs.openstack.org/image-guide/obtain-images.html
sudo wget \
  --continue \
  --output-document=/var/lib/openstack/debian-9-openstack-amd64.qcow2 \
  http://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2

sudo --preserve-env openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file /var/lib/openstack/debian-9-openstack-amd64.qcow2 \
  --public \
  debian-9-openstack-amd64
