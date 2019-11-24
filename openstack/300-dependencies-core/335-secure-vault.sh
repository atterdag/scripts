#!/bin/bash

##############################################################################
# Configure HashiCorp Vault to use HTTPS
##############################################################################
# Add CA chain to controller certificate
export VAULT_ADDR='http://127.0.0.1:8200'
vault login -method=userpass username=user password=$(cat ~/.VAULT_USER_PASS)

vault kv get --field=data keystores/${CONTROLLER_FQDN}.p12 \
| tr -d '\n' \
| base64 --decode \
> ${CONTROLLER_FQDN}.p12

openssl pkcs12 \
  -in ${CONTROLLER_FQDN}.p12 \
  -passin pass:${CONTROLLER_KEYSTORE_PASS} \
  -nokeys \
| sudo tee /etc/vault.d/${CONTROLLER_FQDN}.crt

openssl pkcs12 \
  -in ${CONTROLLER_FQDN}.p12 \
  -passin pass:${CONTROLLER_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| sudo tee /etc/vault.d/${CONTROLLER_FQDN}.key

cat << EOF | sudo tee /etc/vault.d/vault.hcl
listener "tcp" {
  address       = "${CONTROLLER_IP_ADDRESS}:8200"
  tls_cert_file = "/etc/vault.d/${CONTROLLER_FQDN}.crt"
  tls_key_file  = "/etc/vault.d/${CONTROLLER_FQDN}.key"
}

storage "file" {
  path = "/var/lib/vault/data"
}

api_addr = "https://${CONTROLLER_IP_ADDRESS}:8200"
cluster_addr = "https://${CONTROLLER_IP_ADDRESS}:8201"
ui = true
EOF

sudo chown --recursive vault:vault \
  /etc/vault.d \
  /var/lib/vault
sudo chmod 0640 \
  /etc/vault.d/vault.hcl \
  /etc/vault.d/${CONTROLLER_FQDN}.crt \
  /etc/vault.d/${CONTROLLER_FQDN}.key
sudo chmod 0750 \
  /var/lib/vault

# Enable systemd service, and start it
sudo systemctl restart vault
sudo systemctl status vault
sleep 5

# Unseal vault
export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault operator unseal $(sudo grep "Unseal Key 1:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 2:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 3:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault status
