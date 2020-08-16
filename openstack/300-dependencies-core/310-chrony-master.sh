#!/bin/bash

##############################################################################
# Install NTP on Controller host
##############################################################################
sudo apt-get --yes --quiet install \
  chrony

sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.org

cat <<EOT | sudo tee -a /etc/chrony/chrony.conf
allow ${NETWORK_CIDR}
EOT

if [[ $NTP_TWO_IP_ADDRESS != "" ]]; then
  case $(hostname -i) in
    $NTP_ONE_IP_ADDRESS)
      NTP_PEER=$NTP_TWO_IP_ADDRESS
      ;;
    $NTP_TWO_IP_ADDRESS)
      NTP_PEER=$NTP_ONE_IP_ADDRESS
      ;;
esac
  cat <<EOT | sudo tee -a /etc/chrony/chrony.conf
peer $NTP_PEER
EOT
fi

sudo chmod 0644 /etc/chrony/chrony.conf
sudo chown root:root /etc/chrony/chrony.conf
sudo systemctl restart chrony

cat <<EOF | sudo tee /etc/ufw/applications.d/chrony
[chrony]
title=Chrony
description=Versatile implementation of the Network Time Protocol
ports=123/udp

[chronyc]
title=Chrony Control
description=A distributed, reliable key-value store for the most critical data of a distributed system.
ports=323/udp
EOF
sudo ufw allow chrony
sudo ufw allow chronyc
