#!/bin/bash

##############################################################################
# Remove all Python modules installed by pip, and reset to package versions
##############################################################################
sudo apt-get --yes --quiet install \
  python3-pip

for i in $(pip3 list | awk '{print $1}' | grep -v ^Package | grep -v ^---------------------); do
  sudo pip3 uninstall --yes $i
done

for i in $(pip3 list --user | awk '{print $1}' | grep -v ^Package | grep -v ^---------------------); do
  pip3 uninstall --yes $i
done

for i in $(pip3 list --local | awk '{print $1}' | grep -v ^Package | grep -v ^---------------------); do
  pip3 uninstall --yes $i
done

for i in $(sudo pip list | awk '{print $1}' | grep -v ^Package | grep -v ^---------------------); do
  sudo pip uninstall --yes $i
done

sudo apt-get --reinstall --yes --quiet install \
  $(echo $(dpkg -l | awk '{print $2}' | tail -n +5 | grep -E "^python3-|^python-") | sed 's|\n| |g')
