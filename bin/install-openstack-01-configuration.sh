#!/bin/sh

##############################################################################
# Ensure you can sudo to root
##############################################################################
sudo -i id

##############################################################################
# Create function to generate passwords
##############################################################################
genpasswd() {
	local l=$1
       	[ "$l" == "" ] && l=16
      	tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}
##############################################################################
# Create directory to store openstack files
##############################################################################
sudo mkdir -p /var/lib/openstack/
sudo chown root:root /var/lib/openstack/
sudo chmod 0700 /var/lib/openstack/

##############################################################################
# Install HashiCorp Vault on Controller node, so we can store secrets securely
# NB We install Dogtag KRA later, so we only use HashiCorp Vault to store
#    OS, and other core component secrets.
##############################################################################
sudo apt-get install html2text
VAULT_VERSION=$(curl \
  --silent https://releases.hashicorp.com/vault/ \
| html2text \
| grep vault \
| grep -v beta \
| head -1 \
| sed 's/^.*\*\svault_//')

sudo curl \
  --output /var/lib/openstack/vault_${VAULT_VERSION}_linux_amd64.zip\
  https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

sudo unzip \
  -d /usr/local/bin/ \
  /var/lib/openstack/vault_${VAULT_VERSION}_linux_amd64.zip

# Add vault autocomplete
echo "complete -C /usr/local/bin/vault vault" \
| sudo tee /etc/profile.d/99-vault_completion.sh

# Give Vault the ability to use the mlock syscall without running the process as root.
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault

# Create service account
sudo useradd \
  --system \
  --home /etc/vault.d \
  --shell /bin/false vault

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
sudo chown --recursive vault:vault /etc/vault.d
sudo chmod 640 /etc/vault.d/vault.hcl
sudo chown -R vault:vault /var/lib/vault
sudo chmod -R 0750 /var/lib/vault

# Enable systemd service, and start it
sudo systemctl enable vault
sudo systemctl start vault
sudo systemctl status vault

# We have to change the default address because we have not enabled HTTPS yet
export VAULT_ADDR='http://127.0.0.1:8200'

# Initialize Vault - Obviously its a bad idea to store the keys, and tokens
# on the same server as HashiCorp Vault. So please ensure to split up the keys
# in /var/lib/openstack/vault_keys.txt, and move them to seperate locations.
# As putting the root token in a secure location ... and delete
# /var/lib/openstack/vault_keys.txt.
vault operator init \
| sudo tee /var/lib/openstack/vault_keys.txt

# We have to unseal the vault using 3 key shards
vault operator unseal $(sudo grep "Unseal Key 1:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 2:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 3:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault status | grep Sealed

# Set the root token so we can add some root data
export VAULT_TOKEN=$(sudo grep "Initial Root Token:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')

# Enable user authentication
vault auth enable -local userpass

# Generate a secret for the local vault user with the root token
export VAULT_LOCAL_PASS=$(genpasswd 32)

# Enable key vault version 2 in secret path
vault secrets enable -path=secret/ kv-v2

# Create policy that allows users to read secrets in secret/*
cat << EOF | vault policy write secret_read -
path "secret/*"
{
  capabilities = ["read"]
}
EOF

# Put the local user secret in the root data for later retrieval
vault kv put secret/VAULT_LOCAL_PASS value=$(genpasswd 32)

# Create local user in vault, that we can use for future authentication
vault write \
  auth/userpass/users/local \
  password=${VAULT_LOCAL_PASS} \
  policies=secret_read

##############################################################################
# Set passwords in Vault on controller node
##############################################################################
vault kv put secret/ADMIN_PASS value=$(genpasswd 16)
vault kv put secret/BARBICAN_DBPASS value=$(genpasswd 16)
vault kv put secret/BARBICAN_KEK=$(echo $(genpasswd 32) | base64)
vault kv put secret/BARBICAN_PASS value=$(genpasswd 16)
vault kv put secret/CA_PASSWORD value=$(genpasswd 32)
vault kv put secret/CINDER_DBPASS value=$(genpasswd 16)
vault kv put secret/CINDER_PASS value=$(genpasswd 16)
vault kv put secret/COMPUTE_KEYSTORE_PASS value=$(genpasswd 16)
vault kv put secret/CONTROLLER_KEYSTORE_PASS value=$(genpasswd 16)
vault kv put secret/DASH_DBPASS value=$(genpasswd 16)
vault kv put secret/DEMO_PASS value=$(genpasswd 16)
vault kv put secret/DESIGNATE_DBPASS value=$(genpasswd 16)
vault kv put secret/DESIGNATE_PASS value=$(genpasswd 16)
vault kv put secret/DS_ADMIN_PASS value=$(genpasswd 16)
vault kv put secret/DS_ROOT_PASS value=$(genpasswd 16)
vault kv put secret/GLANCE_DBPASS value=$(genpasswd 16)
vault kv put secret/GLANCE_PASS value=$(genpasswd 16)
vault kv put secret/KERBEROS_MASTER_SECRET value=$(genpasswd 32)
vault kv put secret/KEYSTONE_DBPASS value=$(genpasswd 16)
vault kv put secret/METADATA_SECRET value=$(genpasswd 32)
vault kv put secret/NEUTRON_DBPASS value=$(genpasswd 16)
vault kv put secret/NEUTRON_PASS value=$(genpasswd 16)
vault kv put secret/NOVA_DBPASS value=$(genpasswd 16)
vault kv put secret/NOVA_PASS value=$(genpasswd 16)
vault kv put secret/PKI_ADMIN_PASSWORD value=$(genpasswd 16)
vault kv put secret/PKI_BACKUP_PASSWORD value=$(genpasswd 16)
vault kv put secret/PKI_CLIENT_DATABASE_PASSWORD value=$(genpasswd 16)
vault kv put secret/PKI_CLIENT_PKCS12_PASSWORD value=$(genpasswd 16)
vault kv put secret/PKI_CLONE_PKCS12_PASSWORD value=$(genpasswd 16)
vault kv put secret/PKI_REPLICATION_PASSWORD value=$(genpasswd 16)
vault kv put secret/PKI_SECURITY_DOMAIN_PASSWORD value=$(genpasswd 16)
vault kv put secret/PKI_SERVER_DATABASE_PASSWORD value=$(genpasswd 16)
vault kv put secret/PKI_TOKEN_PASSWORD value=$(genpasswd 16)
vault kv put secret/PLACEMENT_DBPASS value=$(genpasswd 16)
vault kv put secret/PLACEMENT_PASS value=$(genpasswd 16)
vault kv put secret/RABBIT_PASS value=$(genpasswd 16)
vault kv put secret/ROOT_DBPASS value=$(genpasswd 16)

##############################################################################
# Unset VAULT_TOKEN
##############################################################################
unset VAULT_TOKEN

##############################################################################
# Set OS password variables
##############################################################################
vault login -method=userpass username=local password=$VAULT_LOCAL_PASS

export ADMIN_PASS=$(vault kv get -field=value secret/ADMIN_PASS)
export BARBICAN_DBPASS=$(vault kv get -field=value secret/BARBICAN_DBPASS)
export BARBICAN_PASS=$(vault kv get -field=value secret/BARBICAN_PASS)
export BARBICAN_KEK=$(echo $(vault kv get -field=value secret/BARBICAN_KEK) | base64)
export CA_PASSWORD=$(vault kv get -field=value secret/CA_PASSWORD)
export CINDER_DBPASS=$(vault kv get -field=value secret/CINDER_DBPASS)
export CINDER_PASS=$(vault kv get -field=value secret/CINDER_PASS)
export CONTROLLER_KEYSTORE_PASS=$(vault kv get -field=value secret/CONTROLLER_KEYSTORE_PASS)
export COMPUTE_KEYSTORE_PASS=$(vault kv get -field=value secret/COMPUTE_KEYSTORE_PASS)
export DASH_DBPASS=$(vault kv get -field=value secret/DASH_DBPASS)
export DEMO_PASS=$(vault kv get -field=value secret/DEMO_PASS)
export DESIGNATE_PASS=$(vault kv get -field=value secret/DESIGNATE_PASS)
export DESIGNATE_DBPASS=$(vault kv get -field=value secret/DESIGNATE_DBPASS)
export DS_ADMIN_PASS=$(vault kv get -field=value secret/DS_ADMIN_PASS)
export DS_ROOT_PASS=$(vault kv get -field=value secret/DS_ROOT_PASS)
export GLANCE_DBPASS=$(vault kv get -field=value secret/GLANCE_DBPASS)
export GLANCE_PASS=$(vault kv get -field=value secret/GLANCE_PASS)
export KERBEROS_MASTER_SECRET=$(vault kv get -field=value secret/KERBEROS_MASTER_SECRET)
export KEYSTONE_DBPASS=$(vault kv get -field=value secret/KEYSTONE_DBPASS)
export METADATA_SECRET=$(vault kv get -field=value secret/METADATA_SECRET)
export NEUTRON_DBPASS=$(vault kv get -field=value secret/NEUTRON_DBPASS)
export NEUTRON_PASS=$(vault kv get -field=value secret/NEUTRON_PASS)
export NOVA_DBPASS=$(vault kv get -field=value secret/NOVA_DBPASS)
export NOVA_PASS=$(vault kv get -field=value secret/NOVA_PASS)
export PKI_ADMIN_PASSWORD=$(vault kv get -field=value secret/PKI_ADMIN_PASSWORD)
export PKI_BACKUP_PASSWORD=$(vault kv get -field=value secret/PKI_BACKUP_PASSWORD)
export PKI_CLIENT_DATABASE_PASSWORD=$(vault kv get -field=value secret/PKI_CLIENT_DATABASE_PASSWORD)
export PKI_CLIENT_PKCS12_PASSWORD=$(vault kv get -field=value secret/PKI_CLIENT_PKCS12_PASSWORD)
export PKI_CLONE_PKCS12_PASSWORD=$(vault kv get -field=value secret/PKI_CLONE_PKCS12_PASSWORD)
export PKI_REPLICATION_PASSWORD=$(vault kv get -field=value secret/PKI_REPLICATION_PASSWORD)
export PKI_SECURITY_DOMAIN_PASSWORD=$(vault kv get -field=value secret/PKI_SECURITY_DOMAIN_PASSWORD)
export PKI_SERVER_DATABASE_PASSWORD=$(vault kv get -field=value secret/PKI_SERVER_DATABASE_PASSWORD)
export PKI_TOKEN_PASSWORD=$(vault kv get -field=value secret/PKI_TOKEN_PASSWORD)
export PLACEMENT_PASS=$(vault kv get -field=value secret/PLACEMENT_PASS)
export PLACEMENT_DBPASS=$(vault kv get -field=value secret/PLACEMENT_DBPASS)
export RABBIT_PASS=$(vault kv get -field=value secret/RABBIT_PASS)
export ROOT_DBPASS=$(vault kv get -field=value secret/ROOT_DBPASS)
export VAULT_LOCAL_PASS=$(vault kv get -field=value secret/VAULT_LOCAL_PASS)

##############################################################################
# Set OS infrastructure variables
##############################################################################
cat << EOF | sudo tee /var/lib/openstack/os_environment.env
# Specified values
export DNS_DOMAIN='se.lemche.net'
export CONTROLLER_IP_ADDRESS='192.168.1.30'
export COMPUTE_IP_ADDRESS='192.168.1.30'
export LVM_PREMIUM_PV_DEVICE='sde'
export LVM_STANDARD_PV_DEVICE='sdb'
export NETWORK_CIDR='192.168.1.0/24'
export NETWORK_INTERFACE='eno1'
export SIMPLE_CRYPTO_CA='OpenStack'
export SSL_ROOT_CA_COMMON_NAME='Lemche.NET Root CA'
export SSL_INTERMEDIATE_CA_ONE_COMMON_NAME='Lemche.NET Intermediate CA 1'
export SSL_INTERMEDIATE_CA_TWO_COMMON_NAME='Lemche.NET Intermediate CA 2'
export SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME='Lemche.NET Intermediate AUDIT 2'
export SSL_COUNTRY_NAME='SE'
export SSL_STATE='Scania'
export SSL_ORGANIZATION_NAME='Lemche.NET'
export SSL_ORGANIZATIONAL_UNIT_NAME='Security Operation Center'
export SSL_PKI_INSTANCE_NAME='pki-tomcat'

# Calculated values
export CONTROLLER_FQDN="jack.\${DNS_DOMAIN}"
export COMPUTE_FQDN="jack.\${DNS_DOMAIN}"
export DNS_REVERSE_DOMAIN=\$(echo \${CONTROLLER_IP_ADDRESS} | awk -F'.' '{print \$3"."\$2"."\$1}').in-addr.arpa
export DS_SUFFIX='dc='\$(echo \${DNS_DOMAIN} | sed 's|\.|,dc=|g')
export SSL_BASE_URL="http://ca.\${DNS_DOMAIN}"
export SSL_BASE_DIR="/var/lib/ssl/\${SSL_ORGANIZATION_NAME}"
export SSL_CA_EMAIL="ca@${DNS_DOMAIN}"
export SSL_ROOT_CA_STRICT_NAME=\$(echo \${SSL_ROOT_CA_COMMON_NAME} | sed 's/\s/_/g')
export SSL_INTERMEDIATE_CA_ONE_STRICT_NAME=\$(echo \${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME} | sed 's/\s/_/g')
export SSL_INTERMEDIATE_CA_TWO_STRICT_NAME=\$(echo \${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME} | sed 's/\s/_/g')
export SSL_INTERMEDIATE_OCSP_ONE_FQDN="ocsp.\${DNS_DOMAIN}"
export SSL_INTERMEDIATE_OCSP_TWO_FQDN="jack.\${DNS_DOMAIN}"
export SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME=\$(echo \${SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME} | sed 's/\s/_/g')
EOF
source <(sudo cat /var/lib/openstack/os_environment.env)

##############################################################################
# Setting up compute node
##############################################################################
# Copy env files to compute node
export VAULT_ADDR="http://${CONTROLLER_FQDN}:8200"
export VAULT_LOCAL_PASS=<get it from controller>
vault login -method=userpass username=local password=$VAULT_LOCAL_PASS
# Run export commands in "Set OS password variables"
source <(sudo cat /var/lib/openstack/os_environment.env)
