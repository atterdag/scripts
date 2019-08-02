#!/bin/bash

##############################################################################
# Enable the OpenStack repository
##############################################################################
sudo apt-get --yes install software-properties-common
sudo add-apt-repository --yes cloud-archive:rocky
sudo apt-get update
sudo apt-get --yes dist-upgrade
