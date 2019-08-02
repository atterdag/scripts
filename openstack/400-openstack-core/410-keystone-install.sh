#!/bin/bash

##############################################################################
# Install Keystone on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  keystone \
  libapache2-mod-wsgi
