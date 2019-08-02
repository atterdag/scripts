#!/bin/bash

##############################################################################
# Install Keystone on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  keystone \
  libapache2-mod-wsgi
