#!/bin/bash

##############################################################################
# Install OpenSSL on Controller host
##############################################################################
sudo apt-get install --yes --quiet \
  ca-certificates \
  openssl \
  ssl-cert
