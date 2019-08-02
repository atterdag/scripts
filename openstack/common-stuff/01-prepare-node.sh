#!/bin/bash

##############################################################################
# Getting the environment up for a node
##############################################################################
# You have to set these by hand
export CONTROLLER_FQDN=jack.se.lemche.net
 export VAULT_USER_PASS=$(cat $(dirname $0)/.VAULT_USER_PASS)

# Create variables with infrastructure configuration
export ETCDCTL_ENDPOINTS="http://${CONTROLLER_FQDN}:2379"
for key in $(etcdctl ls variables/ | sed 's|^/variables/||'); do
	export eval $key="$(etcdctl get variables/$key)"
done

# Create variables with secrets
export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault login -method=userpass username=user password=$VAULT_USER_PASS
for secret in $(vault kv list -format yaml passwords/ | sed 's/^-\s//'); do
	export eval $secret="$(vault kv get -field=value passwords/$secret)"
done

source <(sudo cat /var/lib/openstack/admin-openrc)
