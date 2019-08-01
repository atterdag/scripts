#!/bin/sh

##############################################################################
# Install Queue Manager on Controller host
##############################################################################
sudo apt-get --yes install rabbitmq-server

sudo rabbitmqctl add_user openstack $RABBIT_PASS
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"
