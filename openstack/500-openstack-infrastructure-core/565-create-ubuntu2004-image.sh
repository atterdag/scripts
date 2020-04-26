#!/bin/bash

##############################################################################
# Create ubuntu-18.04-server-cloudimg-amd64 images on Controller host
##############################################################################
# Ref https://docs.openstack.org/image-guide/obtain-images.html
sudo wget \
  --continue \
  --output-document=${OPENSTACK_IMAGES_DIRECTORY}/ubuntu-20.04-server-cloudimg-amd64.img \
  https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file ${OPENSTACK_IMAGES_DIRECTORY}/ubuntu-20.04-server-cloudimg-amd64.img \
  --public \
  ubuntu-20.04-server-cloudimg-amd64
