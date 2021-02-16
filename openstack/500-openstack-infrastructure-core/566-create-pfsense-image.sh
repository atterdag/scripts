#!/bin/bash

##############################################################################
# Create ubuntu-18.04-server-cloudimg-amd64 images on Controller host
##############################################################################
# Ref https://docs.openstack.org/image-guide/obtain-images.html
sudo wget \
  --continue \
  --output-document=${OS_IMAGES_DIRECTORY}/pfSense-CE-memstick-2.4.5-RELEASE-amd64.img.gz \
  https://frafiles.pfsense.org/mirror/downloads/pfSense-CE-memstick-2.4.5-RELEASE-amd64.img.gz

gunzip ${OS_IMAGES_DIRECTORY}/pfSense-CE-memstick-2.4.5-RELEASE-amd64.img.gz

openstack image create \
  --container-format bare \
  --disk-format raw \
  --file ${OS_IMAGES_DIRECTORY}/pfSense-CE-memstick-2.4.5-RELEASE-amd64.img \
  --public \
  pfSense-CE-memstick-2.4.5-RELEASE-amd64
