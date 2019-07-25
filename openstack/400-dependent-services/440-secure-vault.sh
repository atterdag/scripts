#!/bin/sh

##############################################################################
# Configure HashiCorp Vault to use HTTPS
##############################################################################
# Add CA chain to controller certificate
cat \
  /etc/ssl/certs/${CONTROLLER_FQDN}.crt \
  ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
| sudo tee /etc/ssl/certs/${CONTROLLER_FQDN}_CA_Chain.crt

cat << EOF | sudo tee /etc/vault.d/vault.hcl
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/etc/ssl/certs/${CONTROLLER_FQDN}_CA_Chain.crt"
  tls_key_file  = "/etc/ssl/private/${CONTROLLER_FQDN}.key"
}

storage "file" {
  path = "/var/lib/vault/data"
}

api_addr = "https://0.0.0.0:8200"
cluster_addr = "https://0.0.0.0:8201"
ui = true
EOF

# Make the vault runtime user a member of ssl-cert
sudo usermod -a -G ssl-cert vault

# Enable systemd service, and start it
sudo systemctl restart vault
sudo systemctl status vault

# Check that you can communicate with HashiCorp Vault
export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault status
