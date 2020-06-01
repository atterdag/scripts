#!/bin/bash

##############################################################################
# Install ufw on etcd host
##############################################################################
sudo apt-get --yes --quiet install \
  ufw

sudo ufw allow OpenSSH
yes | sudo ufw enable
