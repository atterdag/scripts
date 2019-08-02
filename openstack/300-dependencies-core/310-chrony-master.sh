#!/bin/bash

##############################################################################
# Install NTP on Controller host
##############################################################################
sudo apt-get --yes install chrony

sudo mv /etc/chrony/chrony.conf /etc/chrony/chrony.conf.org

cat << EOT | sudo tee -a /etc/chrony/chrony.conf
allow ${NETWORK_CIDR}
EOT

sudo chmod 0644 /etc/chrony/chrony.conf
sudo chown root:root /etc/chrony/chrony.conf
sudo systemctl restart chrony
