#!/bin/bash

##############################################################################
# Create ubuntu-18.04-server-cloudimg-amd64 images on Controller host
##############################################################################
# Ref https://docs.openstack.org/image-guide/obtain-images.html
sudo wget \
  --continue \
  --output-document=${OPENSTACK_CONFIGURATION_DIRECTORY}/ubuntu-18.04-server-cloudimg-amd64.img \
  https://cloud-images.ubuntu.com/releases/server/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img

sudo --preserve-env openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file ${OPENSTACK_CONFIGURATION_DIRECTORY}/ubuntu-18.04-server-cloudimg-amd64.img \
  --public \
  ubuntu-18.04-server-cloudimg-amd64
