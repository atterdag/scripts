#!/bin/sh

##############################################################################
# Setting up compute node
##############################################################################
# You have to set these by hand
export CONTROLLER_FQDN=
export SSL_ROOT_CA_FQDN=
export VAULT_OPENSTACK_PASS=

# Get list of CA certifiates
CA_CERTIFICATES=$(curl \
  --silent \
	http://${SSL_ROOT_CA_FQDN}/ \
| html2text \
| grep .crt \
| awk '{print $3}')

# Download each CA certificate
for ca_certificate in $CA_CERTIFICATES; do
	sudo curl \
	  --output /usr/local/share/ca-certificates/${ca_certificate} \
		--silent \
	  http://${SSL_ROOT_CA_FQDN}/${ca_certificate}
done

# Install CA certifiates
sudo update-ca-certificates

# Create variables with secrets
export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault login -method=userpass username=openstack password=$VAULT_OPENSTACK_PASS
for secret in $(vault kv list -format yaml openstack/ | sed 's/^-\s//'); do
	export eval $secret="$(vault kv get -field=value openstack/$secret)"
done

# Create variables with infrastructure configuration
export ETCDCTL_ENDPOINTS="https://${CONTROLLER_FQDN}:2379"
for key in $(etcdctl ls openstack/ | sed 's|^/openstack/||'); do
	export eval $key="$(etcdctl get openstack/$key)"
done
