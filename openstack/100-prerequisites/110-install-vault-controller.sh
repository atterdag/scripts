#!/bin/sh

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
| grep -v rc \
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
