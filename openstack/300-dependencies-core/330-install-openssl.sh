#!/bin/bash

##############################################################################
# Install OpenSSL on Controller host
##############################################################################
sudo apt-get --yes --quiet install \
  ca-certificates \
  openssl \
  ssl-cert
