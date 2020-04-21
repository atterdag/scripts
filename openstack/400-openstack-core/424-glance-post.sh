#!/bin/bash

##############################################################################
# Ensure Glance works on Controller host
##############################################################################
for version in 0.4.0 0.5.0 0.5.1; do
  sudo wget \
    --continue \
    --output-document=${OPENSTACK_CONFIGURATION_DIRECTORY}/cirros-${version}-x86_64-disk.version \
    http://download.cirros-cloud.net/${version}/cirros-${version}-x86_64-disk.version

  sudo --preserve-env openstack image create "cirros-${version}" \
    --file ${OPENSTACK_CONFIGURATION_DIRECTORY}/cirros-${version}-x86_64-disk.version \
    --disk-format qcow2 \
    --container-format bare \
    --public
done

openstack image list
