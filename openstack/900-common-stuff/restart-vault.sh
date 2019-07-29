#!/bin/sh

##############################################################################
# Getting the environment up for a node
##############################################################################
sudo systemctl restart vault
vault operator unseal $(sudo grep "Unseal Key 1:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 2:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 3:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault status | grep Sealed
