#!/bin/bash

##############################################################################
# Install Memcached on Controller
##############################################################################
sudo apt-get --yes --quiet install \
  memcached \
  python-memcache

sudo sed -i "s/^-l\s.*$/-l ${CONTROLLER_IP_ADDRESS}/" /etc/memcached.conf
sudo systemctl restart memcached
