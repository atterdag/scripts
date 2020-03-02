#!/bin/bash

##############################################################################
# Install Etcd on Controller host
##############################################################################
sudo add-apt-repository --enable-source --yes --update universe
sudo apt-get --yes --quiet install \
  etcd
sudo systemctl enable etcd
sudo systemctl start etcd
