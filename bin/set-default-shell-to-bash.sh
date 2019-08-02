#!/bin/bash

##############################################################################
# Set default shell to bash
##############################################################################
echo 'dash dash/sh boolean false' | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
