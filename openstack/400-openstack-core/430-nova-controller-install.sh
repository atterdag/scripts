#!/bin/bash

##############################################################################
# Install Nova on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  nova-api \
  nova-conductor \
  nova-console \
  nova-consoleauth \
  nova-novncproxy \
  nova-xvpvncproxy \
  nova-scheduler \
  nova-placement-api
