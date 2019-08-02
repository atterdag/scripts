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
  nova-compute \
  nova-novncproxy \
  nova-conductor \
  nova-scheduler \
  nova-consoleauth \
  nova-console \
  nova-xvpvncproxy \
  nova-api \
  qemu-kvm \
  glance-api \
  glance-registry \
  apache2 \
  etcd \
  memcached \
  rabbitmq-server \
  mysql \
  bind9 \
  chrony

sudo -E nova-status upgrade check
