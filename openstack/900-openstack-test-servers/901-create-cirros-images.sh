#!/bin/bash

##############################################################################
# Ensure Glance works on Controller host
##############################################################################
if [[ ! -d $OS_IMAGES_DIRECTORY ]]; then
  sudo mkdir -p $OS_IMAGES_DIRECTORY
fi

for version in 0.4.0 0.5.0 0.5.1; do
  sudo wget \
    --continue \
    --output-document=${OS_IMAGES_DIRECTORY}/cirros-${version}-x86_64-disk.img \
    http://download.cirros-cloud.net/${version}/cirros-${version}-x86_64-disk.img

  openstack image create "cirros-${version}" \
    --file ${OS_IMAGES_DIRECTORY}/cirros-${version}-x86_64-disk.img \
    --disk-format qcow2 \
    --container-format bare \
    --public
done

openstack image list
