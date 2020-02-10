#!/bin/bash

##############################################################################
# Remove all Python modules installed by pip, and reset to package versions
##############################################################################
sudo apt-get --yes --quiet install \
  python3-pip

for i in $(pip3 list | awk '{print $1}'); do
  sudo --login pip3 uninstall --yes $i
done

sudo apt-get --reinstall --yes --quiet install \
  $(echo $(dpkg -l | awk '{print $2}' | tail -n +5 | grep ^python3-) | sed 's|\n| |g')
