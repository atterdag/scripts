#!/bin/bash

##############################################################################
# List prerequisite resources for creating a server instance on Controller host
##############################################################################
provider_uuid=$(openstack resource provider list -f value -c uuid)
for resource_class in VCPU MEMORY_MB DISK_GB; do
  echo "--- provider inventory: $resource_class ---"
  openstack resource provider inventory show $provider_uuid $resource_class
done
echo "--- provider usage ---"
openstack resource provider usage show $provider_uuid --sort-column name
echo "--- provider trait ---"
openstack resource provider trait list $provider_uuid --sort-column name
