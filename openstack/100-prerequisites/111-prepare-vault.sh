#!/bin/sh


# We have to change the default address because we have not enabled HTTPS yet
export VAULT_ADDR='http://127.0.0.1:8200'

# Initialize Vault - Obviously its a bad idea to store the keys, and tokens
# on the same server as HashiCorp Vault. So please ensure to split up the keys
# in /var/lib/openstack/vault_keys.txt, and move them to seperate locations.
# As putting the root token in a secure location ... and delete of course
# /var/lib/openstack/vault_keys.txt.
vault operator init \
| sudo tee /var/lib/openstack/vault_keys.txt

# We have to unseal the vault using 3 key shards
# !!! Remember you have to unseal vault each time its been restarted.
vault operator unseal $(sudo grep "Unseal Key 1:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 2:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 3:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault status | grep Sealed

# Set the root token so we can add some root data
export VAULT_TOKEN=$(sudo grep "Initial Root Token:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')

# Enable user authentication
vault auth enable -local userpass

# Enable key vault version 2 in ephemeral path for temp data
vault secrets enable -path=ephemeral/ kv-v2

# Enable key vault version 2 in keystores path for certificate keystores
vault secrets enable -path=keystores/ kv-v2

# Enable key vault version 2 in passwords path for secrets
vault secrets enable -path=passwords/ kv-v2

# Enable key vault version 2 in secret path for local users
vault secrets enable -path=secret/ kv

# Create policy that allows users to read secrets
cat << EOF | vault policy write user -
path "ephemeral/*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "keystores/*"
{
  capabilities = ["read", "list"]
}
path "passwords/*"
{
  capabilities = ["read", "list"]
}
EOF

# Create policy that allows users to read secrets
cat << EOF | vault policy write admin -
path "ephemeral/*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "keystores/*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "passwords/*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

# Generate a secret for the local vault user with the root token
export VAULT_USER_PASS=$(genpasswd 32)

# Put the local user secret in the root data for later retrieval
vault write secret/VAULT_USER_PASS value=$VAULT_USER_PASS

# Create local user in vault, that we can use for future authentication
vault write \
  auth/userpass/users/user \
  password=${VAULT_USER_PASS} \
  policies=user

# Generate a secret for the local vault user with the root token
export VAULT_ADMIN_PASS=$(genpasswd 32)

# Put the local user secret in the root data for later retrieval
vault write secret/VAULT_ADMIN_PASS value=$VAULT_ADMIN_PASS

# Create local user in vault, that we can use for future authentication
vault write \
  auth/userpass/users/admin \
  password=${VAULT_ADMIN_PASS} \
  policies=admin

# Unset VAULT_TOKEN
unset VAULT_TOKEN
