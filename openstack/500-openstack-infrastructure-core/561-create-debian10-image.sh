#!/bin/bash

##############################################################################
# Create debian-stretch-amd64 image on Controller host
##############################################################################
# Ref https://docs.openstack.org/image-guide/obtain-images.html
sudo wget \
  --continue \
  --output-document=${OS_IMAGES_DIRECTORY}/debian-10-openstack-amd64.qcow2 \
  http://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.qcow2

openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file ${OS_IMAGES_DIRECTORY}/debian-10-openstack-amd64.qcow2 \
  --public \
  debian-10-openstack-amd64
