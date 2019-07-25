#!/bin/sh

##############################################################################
# Install NTP on Compute host
##############################################################################
sudo apt-get --yes install chrony

sudo mv /etc/chrony/chrony.conf /etc/chrony/chrony.conf.org
cat << EOT | sudo tee /etc/chrony/chrony.conf
server ${CONTROLLER_IP_ADDRESS}
EOT
sudo chmod 0644 /etc/chrony/chrony.conf
sudo chown root:root /etc/chrony/chrony.conf
sudo systemctl restart chrony
