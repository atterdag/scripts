#!/bin/bash

##############################################################################
# Import environment variables, and passwords
##############################################################################
export CONTROLLER_FQDN=aku.se.lemche.net
 export ETCD_USER_PASS=

# Create variables with infrastructure configuration
export ETCDCTL_ENDPOINTS="https://${CONTROLLER_FQDN}:4001"
for key in $(etcdctl ls variables/ | sed 's|^/variables/||'); do
	export eval $key="$(etcdctl get variables/$key)"
done

# Create variables with secrets
for secret in $(etcdctl --username user:$ETCD_USER_PASS ls /passwords/ | sed 's|^/passwords/||'); do
	export eval $secret="$(etcdctl --username user:$ETCD_USER_PASS get /passwords/$secret)"
done

source <(sudo cat /var/lib/openstack/admin-openrc)
