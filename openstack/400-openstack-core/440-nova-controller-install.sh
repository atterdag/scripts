#!/bin/bash

##############################################################################
# Install Nova on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  nova-api \
  nova-conductor \
  nova-novncproxy \
  nova-scheduler

# nova-console \
# nova-consoleauth \
# nova-xvpvncproxy \
