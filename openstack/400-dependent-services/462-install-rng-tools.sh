#!/bin/sh

##############################################################################
# Install rng-tools to improve the quality (entropy) of the randomness
##############################################################################
sudo apt --yes install rng-tools
sudo sed -i 's|#HRNGDEVICE=/dev/null|#HRNGDEVICE=/dev/null\nHRNGDEVICE=/dev/urandom|' /etc/default/rng-tools
sudo systemctl restart rng-tools
