#!/bin/bash

##############################################################################
# Install DogTag
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --purge remove \
  openjdk*

sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --purge autoremove

for i in $(dpkg -l | grep ^rc | awk '{print $2}'); do sudo dpkg -P $i; done

sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install \
  openjdk-8-jre-headless \
  pki-ca \
  pki-kra \
  liboscache-java \
  libstax-java
