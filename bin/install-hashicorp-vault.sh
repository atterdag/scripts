#!/bin/sh

##############################################################################
# Remove packages on all base packages.
##############################################################################
sudo systemctl stop vault
sudo systemctl disable vault
sudo systemctl daemon-reload
sudo userdel -r vault
sudo rm -fr \
  /etc/vault.d \
  /var/lib/vault \
  /etc/systemd/system/vault.service \
  /usr/local/bin/vault

##############################################################################
# Install HashiCorp Vault on Controller node, so we can store secrets securely
# NB We install Dogtag KRA later, so we only use HashiCorp Vault to store
#    OS, and other core component secrets.
##############################################################################
sudo apt-get --yes --quiet install \
  html2text

VAULT_VERSION=$(curl \
  --silent https://releases.hashicorp.com/vault/ \
| html2text \
| grep vault \
| grep -v beta \
| grep -v rc \
| head -1 \
| sed 's/^.*\*\svault_//')

sudo curl \
  --output /tmp/vault_${VAULT_VERSION}_linux_amd64.zip\
  https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

sudo unzip \
  -d /usr/local/bin/ \
  /tmp/vault_${VAULT_VERSION}_linux_amd64.zip

# Add vault autocomplete
echo "complete -C /usr/local/bin/vault vault" \
| sudo tee /etc/profile.d/99-vault_completion.sh

# Give Vault the ability to use the mlock syscall without running the process as root.
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault

# Create service account
sudo useradd \
  --system \
  --home /etc/vault.d \
  --shell /bin/false \
  vault

# Configure Vault
sudo mkdir \
  --parents \
  /etc/vault.d \
  /var/lib/vault/data

cat << EOF | sudo tee /etc/vault.d/vault.hcl
listener "tcp" {
  # Until we have a PKI we have to start vault without HTTPS
  tls_disable   = "true"
  # But we'll only listen to localhost
  address       = "127.0.0.1:8200"
}

storage "file" {
  path = "/var/lib/vault/data"
}

api_addr = "https://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
ui = true
EOF
sudo chown --recursive vault:vault /etc/vault.d /var/lib/vault
sudo chmod 0640 /etc/vault.d/vault.hcl
sudo chmod 0750 /var/lib/vault

# Create systemd service
cat << EOF | sudo tee /etc/systemd/system/vault.service
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitIntervalSec=60
StartLimitBurst=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Enable systemd service, and start it
sudo systemctl enable vault
sudo systemctl start vault
sudo systemctl status vault

##############################################################################
# Install HashiCorp Vault on Server node.
##############################################################################
source /etc/profile.d/genpasswd.sh

# We have to change the default address because we have not enabled HTTPS yet
export VAULT_ADDR='http://127.0.0.1:8200'

# Initialize Vault - Obviously its a bad idea to store the keys, and tokens
# on the same server as HashiCorp Vault. So please ensure to split up the keys
# in /var/lib/vault/keys.txt, and move them to seperate locations.
# As putting the root token in a secure location ... and delete of course
# /var/lib/vault/keys.txt.
vault operator init \
| sudo tee /var/lib/vault/keys.txt

# We have to unseal the vault using 3 key shards
# !!! Remember you have to unseal vault each time its been restarted.
vault operator unseal \
  $(sudo grep "Unseal Key 1:" /var/lib/vault/keys.txt | awk -F": " '{print $2}')
vault operator unseal \
  $(sudo grep "Unseal Key 2:" /var/lib/vault/keys.txt | awk -F": " '{print $2}')
vault operator unseal \
  $(sudo grep "Unseal Key 3:" /var/lib/vault/keys.txt | awk -F": " '{print $2}')
vault status | grep Sealed

# Set the root token so we can add some root data
export VAULT_TOKEN=$(sudo grep "Initial Root Token:" /var/lib/vault/keys.txt | awk -F": " '{print $2}')

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
vault write \
  secret/VAULT_USER_PASS \
  value=$VAULT_USER_PASS

# Create local user in vault, that we can use for future authentication
vault write \
  auth/userpass/users/user \
  password=${VAULT_USER_PASS} \
  policies=user

# Generate a secret for the local vault user with the root token
export VAULT_ADMIN_PASS=$(genpasswd 32)

# Put the local user secret in the root data for later retrieval
vault write \
  secret/VAULT_ADMIN_PASS \
  value=$VAULT_ADMIN_PASS

# Create local user in vault, that we can use for future authentication
vault write \
  auth/userpass/users/admin \
  password=${VAULT_ADMIN_PASS} \
  policies=admin

# Unset VAULT_TOKEN
unset VAULT_TOKEN

# This is prolly not a good idea
echo $VAULT_ADMIN_PASS > ~/.VAULT_ADMIN_PASS
echo $VAULT_USER_PASS > ~/.VAULT_USER_PASS

##############################################################################
# Install HashiCorp Vault on Client nodes.
##############################################################################
sudo apt-get --yes --quiet install \
  html2text

VAULT_VERSION=$(curl \
  --silent https://releases.hashicorp.com/vault/ \
| html2text \
| grep vault \
| grep -v beta \
| grep -v rc \
| head -1 \
| sed 's/^.*\*\svault_//')

sudo curl \
  --output /tmp/vault_${VAULT_VERSION}_linux_amd64.zip \
  https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

sudo unzip \
  -d /usr/local/bin/ \
  /tmp/vault_${VAULT_VERSION}_linux_amd64.zip

# Add vault autocomplete
echo "complete -C /usr/local/bin/vault vault" \
| sudo tee /etc/profile.d/99-vault_completion.sh

##############################################################################
# Populate the vault with some secrets.
##############################################################################
export VAULT_ADDR="http://localhost:8200"
source /etc/profile.d/genpasswd.sh
vault login -method=userpass username=admin password=$(cat ~/.VAULT_ADMIN_PASS)
vault kv put passwords/ADMIN_PASS value=$(genpasswd 16)

##############################################################################
# Populate the vault with some secrets.
##############################################################################
echo "Create variables with secrets"
export VAULT_ADDR="http://localhost:8200"
vault login -method=userpass username=user password=$(cat ~/.VAULT_USER_PASS)
for secret in $(vault kv list -format yaml passwords/ | sed 's/^-\s//'); do
	export eval $secret="$(vault kv get -field=value passwords/$secret)"
done

# Upload PKCS#12 keystore to vault
export VAULT_ADDR='http://127.0.0.1:8200'
vault login -method=userpass username=admin password=$(cat ~/.VAULT_ADMIN_PASS)
sudo cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CONTROLLER_FQDN}.p12 \
| base64 \
| vault kv put keystores/${CONTROLLER_FQDN}.p12 data=-

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
vault operator unseal $(sudo grep "Unseal Key 1:" /var/lib/vault/keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 2:" /var/lib/vault/keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 3:" /var/lib/vault/keys.txt | awk -F": " '{print $2}')
vault status

##############################################################################
# Getting the environment up for a node
##############################################################################
# Enable systemd service, and start it
sudo systemctl restart vault
sudo systemctl status vault

# Unseal vault
export VAULT_ADDR="https://$(hostname -f):8200"
vault operator unseal $(sudo grep "Unseal Key 1:" /var/lib/vault/keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 2:" /var/lib/vault/keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 3:" /var/lib/vault/keys.txt | awk -F": " '{print $2}')
vault status

##############################################################################
# Getting the environment up for a node
##############################################################################
# You have to set this by hand
export CONTROLLER_FQDN=aku.se.lemche.net

# You have to set these by hand
if [[ "$CONTROLLER_FQDN" == "" ]]; then
 echo "You have to set CONTROLLER_FQDN variable before sourcing this file!"
 return
fi

# Create variables with secrets
export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault login -method=userpass username=user password=$(cat ~/.VAULT_USER_PASS)
for secret in $(vault kv list -format yaml passwords/ | sed 's/^-\s//'); do
	export eval $secret="$(vault kv get -field=value passwords/$secret)"
done
