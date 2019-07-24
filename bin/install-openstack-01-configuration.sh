#!/bin/sh

##############################################################################
# Ensure you can sudo to root
##############################################################################
sudo -i id

##############################################################################
# Create function to generate passwords
##############################################################################
cat << EOF | sudo tee /etc/profile.d/genpasswd.sh
genpasswd() {
	local l=\$1
       	[ "\$l" == "" ] && l=16
      	tr -dc A-Za-z0-9_ < /dev/urandom | head -c \${l} | xargs
}
EOF
source /etc/profile.d/genpasswd.sh

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
vault operator unseal $(sudo grep "Unseal Key 1:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 2:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault operator unseal $(sudo grep "Unseal Key 3:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')
vault status | grep Sealed

# Set the root token so we can add some root data
export VAULT_TOKEN=$(sudo grep "Initial Root Token:" /var/lib/openstack/vault_keys.txt | awk -F": " '{print $2}')

# Enable user authentication
vault auth enable -local userpass

# Generate a secret for the local vault user with the root token
export VAULT_OPENSTACK_PASS=$(genpasswd 32)

# Enable key vault version 2 in secret path for local users
vault secrets enable -path=secret/ kv-v2

# Create policy that allows users to read secrets in openstack/*
cat << EOF | vault policy write openstack -
path "openstack/*"
{
  capabilities = ["read"]
}
EOF

# Put the local user secret in the root data for later retrieval
vault kv put secret/VAULT_OPENSTACK_PASS value=$VAULT_OPENSTACK_PASS

# Create local user in vault, that we can use for future authentication
vault write \
  auth/userpass/users/openstack \
  password=${VAULT_OPENSTACK_PASS} \
  policies=openstack

##############################################################################
# Set passwords in Vault on controller node
##############################################################################
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

##############################################################################
# Set OS infrastructure variables
##############################################################################
cat << EOF | sudo tee /var/lib/openstack/os_environment.env
# Specified values
export COMPUTE_HOST_NAME='jack'
export COMPUTE_IP_ADDRESS='192.168.1.30'
export CONTROLLER_HOST_NAME='jack'
export CONTROLLER_IP_ADDRESS='192.168.1.30'
export DNS_DOMAIN='se.lemche.net'
export LVM_PREMIUM_PV_DEVICE='sdb'
export LVM_STANDARD_PV_DEVICE='sde'
export NETWORK_CIDR='192.168.1.0/24'
export NETWORK_INTERFACE='eno1'
export SIMPLE_CRYPTO_CA='OpenStack'
export SSL_COUNTRY_NAME='SE'
export SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME='Lemche.NET Intermediate AUDIT 2'
export SSL_INTERMEDIATE_CA_ONE_COMMON_NAME='Lemche.NET Intermediate CA 1'
export SSL_INTERMEDIATE_CA_TWO_COMMON_NAME='Lemche.NET Intermediate CA 2'
export SSL_INTERMEDIATE_OCSP_ONE_HOSTNAME='ocsp1'
export SSL_INTERMEDIATE_OCSP_TWO_HOSTNAME='ocsp2'
export SSL_ORGANIZATION_NAME='Lemche.NET'
export SSL_ORGANIZATIONAL_UNIT_NAME='Security Operation Center'
export SSL_PKI_INSTANCE_NAME='pki-tomcat'
export SSL_ROOT_CA_COMMON_NAME='Lemche.NET Root CA'
export SSL_ROOT_CA_EMAIL_USER='ca'
export SSL_ROOT_CA_HOST_NAME='ca'
export SSL_STATE='Scania'

# Calculated values
export COMPUTE_FQDN="\${COMPUTE_HOST_NAME}.\${DNS_DOMAIN}"
export CONTROLLER_FQDN="\${CONTROLLER_HOST_NAME}.\${DNS_DOMAIN}"
export DNS_REVERSE_DOMAIN=\$(echo \${CONTROLLER_IP_ADDRESS} | awk -F'.' '{print \$3"."\$2"."\$1}').in-addr.arpa
export DS_SUFFIX='dc='\$(echo \${DNS_DOMAIN} | sed 's|\.|,dc=|g')
export SSL_BASE_DIR="/var/lib/ssl/\${SSL_ORGANIZATION_NAME}"
export SSL_BASE_URL="http://\${SSL_ROOT_CA_HOST_NAME}.\${DNS_DOMAIN}"
export SSL_CA_EMAIL="\${SSL_ROOT_CA_EMAIL_USER}@${DNS_DOMAIN}"
export SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME=\$(echo \${SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME} | sed 's/\s/_/g')
export SSL_INTERMEDIATE_CA_ONE_STRICT_NAME=\$(echo \${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME} | sed 's/\s/_/g')
export SSL_INTERMEDIATE_CA_TWO_STRICT_NAME=\$(echo \${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME} | sed 's/\s/_/g')
export SSL_INTERMEDIATE_OCSP_ONE_FQDN="\${SSL_INTERMEDIATE_OCSP_ONE_HOSTNAME}.\${DNS_DOMAIN}"
export SSL_INTERMEDIATE_OCSP_TWO_FQDN="\${SSL_INTERMEDIATE_OCSP_TWO_HOSTNAME}.\${DNS_DOMAIN}"
export SSL_ROOT_CA_STRICT_NAME=\$(echo \${SSL_ROOT_CA_COMMON_NAME} | sed 's/\s/_/g')
EOF
source <(sudo cat /var/lib/openstack/os_environment.env)

##############################################################################
# Set OS infrastructure variables
##############################################################################
etcdctl mk --endpoints "http://127.0.0.1" COMPUTE_HOST_NAME 'jack'
etcdctl mk --endpoints "http://127.0.0.1" COMPUTE_IP_ADDRESS '192.168.1.30'
etcdctl mk --endpoints "http://127.0.0.1" CONTROLLER_HOST_NAME 'jack'
etcdctl mk --endpoints "http://127.0.0.1" CONTROLLER_IP_ADDRESS '192.168.1.30'
etcdctl mk --endpoints "http://127.0.0.1" DNS_DOMAIN 'se.lemche.net'
etcdctl mk --endpoints "http://127.0.0.1" LVM_PREMIUM_PV_DEVICE 'sdb'
etcdctl mk --endpoints "http://127.0.0.1" LVM_STANDARD_PV_DEVICE 'sde'
etcdctl mk --endpoints "http://127.0.0.1" NETWORK_CIDR '192.168.1.0/24'
etcdctl mk --endpoints "http://127.0.0.1" NETWORK_INTERFACE 'eno1'
etcdctl mk --endpoints "http://127.0.0.1" SIMPLE_CRYPTO_CA 'OpenStack'
etcdctl mk --endpoints "http://127.0.0.1" SSL_COUNTRY_NAME 'SE'
etcdctl mk --endpoints "http://127.0.0.1" SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME 'Lemche.NET Intermediate AUDIT 2'
etcdctl mk --endpoints "http://127.0.0.1" SSL_INTERMEDIATE_CA_ONE_COMMON_NAME 'Lemche.NET Intermediate CA 1'
etcdctl mk --endpoints "http://127.0.0.1" SSL_INTERMEDIATE_CA_TWO_COMMON_NAME 'Lemche.NET Intermediate CA 2'
etcdctl mk --endpoints "http://127.0.0.1" SSL_INTERMEDIATE_OCSP_ONE_HOSTNAME 'ocsp1'
etcdctl mk --endpoints "http://127.0.0.1" SSL_INTERMEDIATE_OCSP_TWO_HOSTNAME 'ocsp2'
etcdctl mk --endpoints "http://127.0.0.1" SSL_ORGANIZATION_NAME 'Lemche.NET'
etcdctl mk --endpoints "http://127.0.0.1" SSL_ORGANIZATIONAL_UNIT_NAME 'Security Operation Center'
etcdctl mk --endpoints "http://127.0.0.1" SSL_PKI_INSTANCE_NAME 'pki-tomcat'
etcdctl mk --endpoints "http://127.0.0.1" SSL_ROOT_CA_COMMON_NAME 'Lemche.NET Root CA'
etcdctl mk --endpoints "http://127.0.0.1" SSL_ROOT_CA_EMAIL_USER 'ca'
etcdctl mk --endpoints "http://127.0.0.1" SSL_ROOT_CA_HOST_NAME 'ca'
etcdctl mk --endpoints "http://127.0.0.1" SSL_STATE 'Scania'
etcdctl mk --endpoints "http://127.0.0.1" COMPUTE_FQDN "$(etcdctl get --endpoints "http://127.0.0.1" COMPUTE_HOST_NAME).$(etcdctl get DNS_DOMAIN)"
etcdctl mk --endpoints "http://127.0.0.1" CONTROLLER_FQDN "$(etcdctl get CONTROLLER_HOST_NAME).$(etcdctl get DNS_DOMAIN)"
etcdctl mk --endpoints "http://127.0.0.1" DNS_REVERSE_DOMAIN \$(echo $(etcdctl get CONTROLLER_IP_ADDRESS) | awk -F'.' '{print \$3"."\$2"."\$1)').in-addr.arpa
etcdctl mk --endpoints "http://127.0.0.1" DS_SUFFIX 'dc '\$(echo $(etcdctl get DNS_DOMAIN) | sed 's|\.|,dc |g')
etcdctl mk --endpoints "http://127.0.0.1" SSL_BASE_DIR "/var/lib/ssl/$(etcdctl get SSL_ORGANIZATION_NAME)"
etcdctl mk --endpoints "http://127.0.0.1" SSL_BASE_URL "http://$(etcdctl get SSL_ROOT_CA_HOST_NAME).$(etcdctl get DNS_DOMAIN)"
etcdctl mk --endpoints "http://127.0.0.1" SSL_CA_EMAIL "$(etcdctl get SSL_ROOT_CA_EMAIL_USER)@$(etcdctl get DNS_DOMAIN)"
etcdctl mk --endpoints "http://127.0.0.1" SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME \$(echo $(etcdctl get SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME) | sed 's/\s/_/g')
etcdctl mk --endpoints "http://127.0.0.1" SSL_INTERMEDIATE_CA_ONE_STRICT_NAME \$(echo $(etcdctl get SSL_INTERMEDIATE_CA_ONE_COMMON_NAME) | sed 's/\s/_/g')
etcdctl mk --endpoints "http://127.0.0.1" SSL_INTERMEDIATE_CA_TWO_STRICT_NAME \$(echo $(etcdctl get SSL_INTERMEDIATE_CA_TWO_COMMON_NAME) | sed 's/\s/_/g')
etcdctl mk --endpoints "http://127.0.0.1" SSL_INTERMEDIATE_OCSP_ONE_FQDN "$(etcdctl get SSL_INTERMEDIATE_OCSP_ONE_HOSTNAME).$(etcdctl get DNS_DOMAIN)"
etcdctl mk --endpoints "http://127.0.0.1" SSL_INTERMEDIATE_OCSP_TWO_FQDN "$(etcdctl get SSL_INTERMEDIATE_OCSP_TWO_HOSTNAME).$(etcdctl get DNS_DOMAIN)"
etcdctl mk --endpoints "http://127.0.0.1" SSL_ROOT_CA_STRICT_NAME \$(echo $(etcdctl get SSL_ROOT_CA_COMMON_NAME) | sed 's/\s/_/g')

##############################################################################
# Setting up compute node
##############################################################################
export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
export VAULT_OPENSTACK_PASS=<get it from controller>
vault login -method=userpass username=local password=$VAULT_OPENSTACK_PASS
for secret in $(vault kv list -format yaml openstack/ | sed 's/^-\s//'); do
	export eval $secret="$(vault kv get -field=value openstack/$secret)"
done

done
# Copy os_environment.env file to compute node
source <(sudo cat /var/lib/openstack/os_environment.env)
