#!/bin/bash

##############################################################################
# Install packages prequisite to installing prequisites
##############################################################################
sudo apt-get --yes --quiet install \
  crudini \
  openssl \
  ca-certificates \
  ssl-cert
