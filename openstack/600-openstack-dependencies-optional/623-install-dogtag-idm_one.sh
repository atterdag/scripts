#!/bin/bash

##############################################################################
# Install DogTag
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install \
  pki-ca \
  pki-kra \
  liboscache-java \
  libstax-java
