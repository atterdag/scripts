#!/bin/bash

##############################################################################
# Install Designate Worker on Controller host
##############################################################################
# export ETCDCTL_ENDPOINTS="https://${MANAGEMENT_FQDN}:2379"
# ETCD_USER_PASS=$(cat ~/.ETCD_USER_PASS)
# etcdctl --username user:$ETCD_USER_PASS get keystores/designate.key \
# | tr -d '\n' \
# | base64 --decode \
# > designate.key
# sudo mv designate.key /etc/designate/bind.key
# sudo chown designate:designate /etc/designate/bind.key
# sudo chmod 0640 /etc/designate/bind.key

if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  ssh_cmd="ssh -o StrictHostKeyChecking=no ubuntu@${NS_IP_ADDRESS}"
else
  ssh_cmd=""
fi
cat << EOF | $ssh_cmd sudo tee /etc/designate/pools.yaml
- name: default
  # The name is immutable. There will be no option to change the name after
  # creation and the only way will to change it will be to delete it
  # (and all zones associated with it) and recreate it.
  description: Default Pool

  attributes: {}

  # List out the NS records for zones hosted within this pool
  # This should be a record that is created outside of designate, that
  # points to the public IP of the controller node.
  ns_records:
    - hostname: ${NS_FQDN}.
      priority: 1

  # List out the nameservers for this pool. These are the actual BIND servers.
  # We use these to verify changes have propagated to all nameservers.
  nameservers:
    - host: ${NS_IP_ADDRESS}
      port: 53

  # List out the targets for this pool. For BIND there will be one
  # entry for each BIND server, as we have to run rndc command on each server
  targets:
    - type: bind9
      description: BIND9 Server 1

      # List out the designate-mdns servers from which BIND servers should
      # request zone transfers (AXFRs) from.
      # This should be the IP of the controller node.
      # If you have multiple controllers you can add multiple masters
      # by running designate-mdns on them, and adding them here.
      masters:
        - host: ${NS_IP_ADDRESS}
          port: 5354

      # BIND Configuration options
      options:
        host: ${NS_IP_ADDRESS}
        port: 53
        rndc_host: ${NS_IP_ADDRESS}
        rndc_port: 953
        rndc_key_file: /etc/bind/designate.key
EOF
$ssh_cmd sudo chmod 0660 /etc/designate/designate.conf
$ssh_cmd sudo chown designate:designate /etc/designate/designate.conf

$ssh_cmd sudo usermod -a -G bind designate

$ssh_cmd sudo su -s /bin/sh -c "designate-manage pool update" designate

$ssh_cmd sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  designate-worker \
  designate-producer \
  designate-mdns

$ssh_cmd sudo systemctl restart \
  designate-worker \
  designate-producer \
  designate-mdns
