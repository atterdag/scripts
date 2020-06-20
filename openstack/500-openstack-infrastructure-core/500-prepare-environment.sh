#!/bin/bash

##############################################################################
# Import environment variables, and passwords
##############################################################################
export CONTROLLER_FQDN=aku.se.lemche.net
if [[ -z ${ETCD_USER_PASS+x} ]]; then echo "Fetch from user password from secret management"; read ETCD_USER_PASS; fi

# Create variables with infrastructure configuration
export ETCDCTL_DISCOVERY_SRV="$(hostname -d)"
for key in $(etcdctl ls variables/ | sed 's|^/variables/||'); do
	export eval $key="$(etcdctl get variables/$key)"
done

# Create variables with secrets
for secret in $(etcdctl --username user:$ETCD_USER_PASS ls /passwords/ | sed 's|^/passwords/||'); do
	export eval $secret="$(etcdctl --username user:$ETCD_USER_PASS get /passwords/$secret)"
done

source <(sudo cat ${OPENSTACK_CONFIGURATION_DIRECTORY}/admin-openrc)
