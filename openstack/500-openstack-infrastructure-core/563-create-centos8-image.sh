#!/bin/bash

##############################################################################
# Create CentOS-7-x86_64-GenericCloud image on Controller host
##############################################################################
# Ref https://docs.openstack.org/image-guide/obtain-images.html
sudo wget \
  --continue \
  --output-document=${OS_IMAGES_DIRECTORY}/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2 \
  https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2

openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file ${OS_IMAGES_DIRECTORY}/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2 \
  --public \
  CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64
