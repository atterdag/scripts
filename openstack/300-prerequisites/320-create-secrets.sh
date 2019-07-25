#!/bin/sh

##############################################################################
# Set passwords in Vault on controller node
##############################################################################

# We have to change the default address because we have not enabled HTTPS yet
export VAULT_ADDR='http://127.0.0.1:8200'

# Set the root token so we can add some root data
export VAULT_TOKEN=$(sudo grep "Initial Root Token:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')

# Create policy that allows users to read secrets in openstack/*
cat << EOF | vault policy write openstack -
path "openstack/*"
{
  capabilities = ["read"]
}
EOF

# Generate a secret for the local vault user with the root token
export VAULT_OPENSTACK_PASS=$(genpasswd 32)

# Put the local user secret in the root data for later retrieval
vault kv put secret/VAULT_OPENSTACK_PASS value=$VAULT_OPENSTACK_PASS

# Create local user in vault, that we can use for future authentication
vault write \
  auth/userpass/users/openstack \
  password=${VAULT_OPENSTACK_PASS} \
  policies=openstack

# Enable key vault version 2 in openstack path for OpenStack secrets
vault secrets enable -path=openstack/ kv-v2

vault kv put openstack/ADMIN_PASS value=$(genpasswd 16)
vault kv put openstack/BARBICAN_DBPASS value=$(genpasswd 16)
vault kv put openstack/BARBICAN_KEK=$(echo $(genpasswd 32) | base64)
vault kv put openstack/BARBICAN_PASS value=$(genpasswd 16)
vault kv put openstack/CA_PASSWORD value=$(genpasswd 32)
vault kv put openstack/CINDER_DBPASS value=$(genpasswd 16)
vault kv put openstack/CINDER_PASS value=$(genpasswd 16)
vault kv put openstack/COMPUTE_KEYSTORE_PASS value=$(genpasswd 16)
vault kv put openstack/CONTROLLER_KEYSTORE_PASS value=$(genpasswd 16)
vault kv put openstack/DASH_DBPASS value=$(genpasswd 16)
vault kv put openstack/DEMO_PASS value=$(genpasswd 16)
vault kv put openstack/DESIGNATE_DBPASS value=$(genpasswd 16)
vault kv put openstack/DESIGNATE_PASS value=$(genpasswd 16)
vault kv put openstack/DS_ADMIN_PASS value=$(genpasswd 16)
vault kv put openstack/DS_ROOT_PASS value=$(genpasswd 16)
vault kv put openstack/GLANCE_DBPASS value=$(genpasswd 16)
vault kv put openstack/GLANCE_PASS value=$(genpasswd 16)
vault kv put openstack/KERBEROS_MASTER_SECRET value=$(genpasswd 32)
vault kv put openstack/KEYSTONE_DBPASS value=$(genpasswd 16)
vault kv put openstack/METADATA_SECRET value=$(genpasswd 32)
vault kv put openstack/NEUTRON_DBPASS value=$(genpasswd 16)
vault kv put openstack/NEUTRON_PASS value=$(genpasswd 16)
vault kv put openstack/NOVA_DBPASS value=$(genpasswd 16)
vault kv put openstack/NOVA_PASS value=$(genpasswd 16)
vault kv put openstack/PKI_ADMIN_PASSWORD value=$(genpasswd 16)
vault kv put openstack/PKI_BACKUP_PASSWORD value=$(genpasswd 16)
vault kv put openstack/PKI_CLIENT_DATABASE_PASSWORD value=$(genpasswd 16)
vault kv put openstack/PKI_CLIENT_PKCS12_PASSWORD value=$(genpasswd 16)
vault kv put openstack/PKI_CLONE_PKCS12_PASSWORD value=$(genpasswd 16)
vault kv put openstack/PKI_REPLICATION_PASSWORD value=$(genpasswd 16)
vault kv put openstack/PKI_SECURITY_DOMAIN_PASSWORD value=$(genpasswd 16)
vault kv put openstack/PKI_SERVER_DATABASE_PASSWORD value=$(genpasswd 16)
vault kv put openstack/PKI_TOKEN_PASSWORD value=$(genpasswd 16)
vault kv put openstack/PLACEMENT_DBPASS value=$(genpasswd 16)
vault kv put openstack/PLACEMENT_PASS value=$(genpasswd 16)
vault kv put openstack/RABBIT_PASS value=$(genpasswd 16)
vault kv put openstack/ROOT_DBPASS value=$(genpasswd 16)

# Unset VAULT_TOKEN
unset VAULT_TOKEN

# Set OS password variables
vault login -method=userpass username=local password=$VAULT_OPENSTACK_PASS
for secret in $(vault kv list -format yaml openstack/ | sed 's/^-\s//'); do
	export eval $secret=$(vault kv get -field=value openstack/$secret)
done
