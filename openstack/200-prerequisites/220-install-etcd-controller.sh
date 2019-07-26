#!/bin/sh

##############################################################################
# Install Etcd on Controller host
##############################################################################
sudo apt-get install --yes etcd
sudo systemctl enable etcd
sudo systemctl start etcd
