#!/bin/bash

##############################################################################
# Install rng-tools to improve the quality (entropy) of the randomness
##############################################################################
sudo apt --yes install rng-tools
cat  <<EOF | sudo sed --file - --in-place /etc/default/rng-tools
s|#HRNGDEVICE=/dev/null|#HRNGDEVICE=/dev/null\nHRNGDEVICE=/dev/urandom|
EOF
sudo systemctl restart rng-tools
