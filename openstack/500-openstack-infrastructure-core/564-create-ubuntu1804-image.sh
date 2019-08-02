#!/bin/bash

##############################################################################
# Create ubuntu-18.04-server-cloudimg-amd64 images on Controller host
##############################################################################
# Ref https://docs.openstack.org/image-guide/obtain-images.html
sudo wget \
  --continue \
  --output-document=/var/lib/openstack/ubuntu-18.04-server-cloudimg-amd64.img \
  https://cloud-images.ubuntu.com/releases/server/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img

sudo -E openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file /var/lib/openstack/ubuntu-18.04-server-cloudimg-amd64.img \
  --public \
  ubuntu-18.04-server-cloudimg-amd64
