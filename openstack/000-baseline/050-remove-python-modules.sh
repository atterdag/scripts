#!/bin/bash

##############################################################################
# Remove all Python modules installed by pip, and reset to package versions
##############################################################################
sudo apt-get --yes --quiet install \
  python-pip

for i in $(pip list | awk '{print $1}'); do
  sudo --login pip uninstall --yes $i
done

sudo apt-get --reinstall --yes --quiet install \
  $(echo $(dpkg -l | awk '{print $2}' | tail -n +5 | grep ^python-) | sed 's|\n| |g')
