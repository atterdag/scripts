#!/bin/bash

##############################################################################
# Create CentOS-7-x86_64-GenericCloud image on Controller host
##############################################################################
# Ref https://docs.openstack.org/image-guide/obtain-images.html
sudo wget \
  --continue \
  --output-document=${OPENSTACK_CONFIGURATION_DIRECTORY}/CentOS-7-x86_64-GenericCloud.qcow2 \
  https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2

sudo --preserve-env openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file ${OPENSTACK_CONFIGURATION_DIRECTORY}/CentOS-7-x86_64-GenericCloud.qcow2 \
  --public \
  CentOS-7-x86_64-GenericCloud
