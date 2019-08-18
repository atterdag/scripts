#!/bin/bash

##############################################################################
# Create debian server instance on Controller host
##############################################################################
if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  openstack server create \
    --flavor m1.huge \
    --image ubuntu-18.04-server-cloudimg-amd64 \
    --key-name default \
    --nic port-id=${NS_HOST_NAME} \
    --property hostname="${NS_FQDN}" \
    ${NS_HOST_NAME}

fi

if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  ssh_cmd="ssh -o StrictHostKeyChecking=no ubuntu@${NS_IP_ADDRESS}"
  cat <<EOF | $ssh_cmd sudo tee /etc/rsyslog.d/loghost.conf
*.*                             @loghost.se.lemche.net
EOF
  $ssh_cmd sudo systemctl restart rsyslog
fi
