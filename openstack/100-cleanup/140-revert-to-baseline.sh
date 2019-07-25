#!/bin/sh

##############################################################################
# Remove all packages installed since baseline
##############################################################################
if [[ -f os_installed_packages.txt ]]; then
  # Get current packages installed
  dpkg -l \
  | grep ^ii \
  | awk '{print $2}' \
  > new_packages.txt

  # Remove new packages installed since os_installed_packages.txt was created
  sudo apt-get \
    --purge \
    --yes \
    remove \
    $(cat os_installed_packages.txt new_packages.txt | sort | uniq -u | tr '\n' ' ')
fi
