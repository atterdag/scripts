#!/bin/bash

##############################################################################
# Install Etcd on Controller host
##############################################################################
sudo apt-get --yes --quiet install \
  etcd
sudo systemctl enable etcd
sudo systemctl start etcd
