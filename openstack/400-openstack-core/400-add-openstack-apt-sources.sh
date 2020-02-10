#!/bin/bash

##############################################################################
# Enable the OpenStack repository
##############################################################################
sudo apt-get --yes --quiet install \
  software-properties-common
sudo add-apt-repository --yes \
  cloud-archive:train
sudo apt-get update
sudo apt-get --yes dist-upgrade
