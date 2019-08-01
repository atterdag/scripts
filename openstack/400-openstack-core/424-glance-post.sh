#!/bin/sh

##############################################################################
# Ensure Glance works on Controller host
##############################################################################
sudo wget \
  --continue \
  --output-document=/var/lib/openstack/cirros-0.4.0-x86_64-disk.img \
  http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img

sudo -E openstack image create "cirros-0.4.0" \
  --file /var/lib/openstack/cirros-0.4.0-x86_64-disk.img \
  --disk-format qcow2 \
  --container-format bare \
  --public

openstack image list
