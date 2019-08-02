#!/bin/bash

##############################################################################
# Install NTP on Compute host
##############################################################################
sudo apt-get --yes --quiet install \
  chrony

sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.org

sudo sed --in-place 's|^pool|#pool|g' /etc/chrony/chrony.conf

cat << EOT | sudo tee -a /etc/chrony/chrony.conf
server ${IDM_ONE_IP_ADDRESS}
EOT

sudo chmod 0644 /etc/chrony/chrony.conf
sudo chown root:root /etc/chrony/chrony.conf
sudo systemctl restart chrony
