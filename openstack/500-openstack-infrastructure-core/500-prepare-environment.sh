#!/bin/sh

##############################################################################
# Import environment variables, and passwords
##############################################################################
export CONTROLLER_FQDN=
 export VAULT_USER_PASS=

# Create variables with secrets
vault login -method=userpass username=local password=$VAULT_USER_PASS
for secret in $(vault kv list -format yaml openstack/ | sed 's/^-\s//'); do
	export eval $secret="$(vault kv get -field=value openstack/$secret)"
done

# Create variables with infrastructure configuration
export ETCDCTL_ENDPOINTS="http://${CONTROLLER_FQDN}:2379"
for key in $(etcdctl ls openstack/ | sed 's|^/openstack/||'); do
	export eval $key="$(etcdctl get openstack/$key)"
done

source <(sudo cat /var/lib/openstack/admin-openrc)
