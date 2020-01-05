#!/bin/bash

##############################################################################
# Install Queue Manager on Controller host
##############################################################################
sudo apt-get --yes --quiet install \
  rabbitmq-server

sudo rabbitmqctl add_user openstack $RABBIT_PASS
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"

rabbitmqadmin --bash-completion | sudo tee /etc/bash_completion.d/rabbitmqadmin
