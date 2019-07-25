#!/bin/sh

##############################################################################
# Install Cinder on Compute host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet cinder-volume tgt lvm2 thin-provisioning-tools
