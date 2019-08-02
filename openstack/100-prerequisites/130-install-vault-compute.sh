#!/bin/bash

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
  --output /tmp/vault_${VAULT_VERSION}_linux_amd64.zip \
  https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

sudo unzip \
  -d /usr/local/bin/ \
  /tmp/vault_${VAULT_VERSION}_linux_amd64.zip

# Add vault autocomplete
echo "complete -C /usr/local/bin/vault vault" \
| sudo tee /etc/profile.d/99-vault_completion.sh
