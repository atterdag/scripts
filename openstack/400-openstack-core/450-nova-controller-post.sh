#!/bin/bash

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

# You might have to restart all OS services before this works
sudo systemctl restart \
  apache2 \
  nova-compute \
  nova-novncproxy \
  nova-conductor \
  nova-scheduler \
  nova-consoleauth \
  nova-console \
  nova-xvpvncproxy \
  nova-api \
  qemu-kvm

# You might have to wait a few minutes before the compute provider is
# registered with the placement service.
sudo -E nova-status upgrade check

# Not registered yet:
# +-------------------------------------------------------------------+
# | Upgrade Check Results                                             |
# +-------------------------------------------------------------------+
# | Check: Cells v2                                                   |
# | Result: Success                                                   |
# | Details: None                                                     |
# +-------------------------------------------------------------------+
# | Check: Placement API                                              |
# | Result: Success                                                   |
# | Details: None                                                     |
# +-------------------------------------------------------------------+
# | Check: Resource Providers                                         |
# | Result: Warning                                                   |
# | Details: There are no compute resource providers in the Placement |
# |   service but there are 1 compute nodes in the deployment.        |
# |   This means no compute nodes are reporting into the              |
# |   Placement service and need to be upgraded and/or fixed.         |
# |   See                                                             |
# |   https://docs.openstack.org/nova/latest/user/placement.html      |
# |   for more details.                                               |
# +-------------------------------------------------------------------+
# | Check: Ironic Flavor Migration                                    |
# | Result: Success                                                   |
# | Details: None                                                     |
# +-------------------------------------------------------------------+
# | Check: API Service Version                                        |
# | Result: Success                                                   |
# | Details: None                                                     |
# +-------------------------------------------------------------------+
# | Check: Request Spec Migration                                     |
# | Result: Success                                                   |
# | Details: None                                                     |
# +-------------------------------------------------------------------+
# | Check: Console Auths                                              |
# | Result: Success                                                   |
# | Details: None                                                     |
# +-------------------------------------------------------------------+
#
# All done:
# +--------------------------------+
# | Upgrade Check Results          |
# +--------------------------------+
# | Check: Cells v2                |
# | Result: Success                |
# | Details: None                  |
# +--------------------------------+
# | Check: Placement API           |
# | Result: Success                |
# | Details: None                  |
# +--------------------------------+
# | Check: Resource Providers      |
# | Result: Success                |
# | Details: None                  |
# +--------------------------------+
# | Check: Ironic Flavor Migration |
# | Result: Success                |
# | Details: None                  |
# +--------------------------------+
# | Check: API Service Version     |
# | Result: Success                |
# | Details: None                  |
# +--------------------------------+
# | Check: Request Spec Migration  |
# | Result: Success                |
# | Details: None                  |
# +--------------------------------+
# | Check: Console Auths           |
# | Result: Success                |
# | Details: None                  |
# +--------------------------------+
