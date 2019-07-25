#!/bin/sh

##############################################################################
# Check that Nova Compute is registered on Compute host
##############################################################################
openstack compute service list \
  --service nova-compute

# On controller node restart all nova services
sudo systemctl restart \
  nova-api \
  nova-consoleauth \
  nova-scheduler \
  nova-conductor \
  nova-novncproxy \
  nova-compute

sudo su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

openstack compute service list
openstack catalog list
sudo -E nova-status upgrade check
