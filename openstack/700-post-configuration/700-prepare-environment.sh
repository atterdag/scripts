#!/bin/sh

##############################################################################
# Import environment variables, and passwords
##############################################################################
# Create variables with secrets
export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
export VAULT_OPENSTACK_PASS=<get it from controller>
vault login -method=userpass username=local password=$VAULT_OPENSTACK_PASS
for secret in $(vault kv list -format yaml openstack/ | sed 's/^-\s//'); do
	export eval $secret="$(vault kv get -field=value openstack/$secret)"
done

# Create variables with infrastructure configuration
export ETCDCTL_ENDPOINTS="http://${CONTROLLER_FQDN}:2379"
for key in $(etcdctl ls openstack/ | sed 's|^/openstack/||'); do
	export eval $key="$(etcdctl get openstack/$key)"
done

source <(sudo cat /var/lib/openstack/admin-openrc)
