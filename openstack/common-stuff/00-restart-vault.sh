#!/bin/sh

##############################################################################
# Getting the environment up for a node
##############################################################################
# Enable systemd service, and start it
sudo systemctl restart vault
sudo systemctl status vault

# Unseal vault
export VAULT_ADDR="https://$(hostname -f):8200"
vault operator unseal $(sudo grep "Unseal Key 1:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 2:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 3:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault status
