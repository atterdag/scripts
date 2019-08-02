#!/bin/bash

##############################################################################
# Set passwords in Vault on controller node
##############################################################################
source /etc/profile.d/genpasswd.sh
vault login -method=userpass username=admin password=$(cat ~/.VAULT_ADMIN_PASS)
vault kv put passwords/ADMIN_PASS value=$(genpasswd 16)
vault kv put passwords/BARBICAN_DBPASS value=$(genpasswd 16)
vault kv put passwords/BARBICAN_KEK value=$(echo $(genpasswd 32) | base64)
vault kv put passwords/BARBICAN_PASS value=$(genpasswd 16)
vault kv put passwords/CINDER_DBPASS value=$(genpasswd 16)
vault kv put passwords/CINDER_PASS value=$(genpasswd 16)
vault kv put passwords/DASH_DBPASS value=$(genpasswd 16)
vault kv put passwords/DEMO_PASS value=$(genpasswd 16)
vault kv put passwords/DESIGNATE_DBPASS value=$(genpasswd 16)
vault kv put passwords/DESIGNATE_PASS value=$(genpasswd 16)
vault kv put passwords/GLANCE_DBPASS value=$(genpasswd 16)
vault kv put passwords/GLANCE_PASS value=$(genpasswd 16)
vault kv put passwords/KEYSTONE_DBPASS value=$(genpasswd 16)
vault kv put passwords/METADATA_SECRET value=$(genpasswd 32)
vault kv put passwords/NEUTRON_DBPASS value=$(genpasswd 16)
vault kv put passwords/NEUTRON_PASS value=$(genpasswd 16)
vault kv put passwords/NOVA_DBPASS value=$(genpasswd 16)
vault kv put passwords/NOVA_PASS value=$(genpasswd 16)
vault kv put passwords/PLACEMENT_DBPASS value=$(genpasswd 16)
vault kv put passwords/PLACEMENT_PASS value=$(genpasswd 16)
vault kv put passwords/RABBIT_PASS value=$(genpasswd 16)
vault kv put passwords/ROOT_DBPASS value=$(genpasswd 16)
vault kv put passwords/CA_PASSWORD value=$(genpasswd 32)
vault kv put passwords/COMPUTE_KEYSTORE_PASS value=$(genpasswd 16)
vault kv put passwords/CONTROLLER_KEYSTORE_PASS value=$(genpasswd 16)
vault kv put passwords/DS_ADMIN_PASS value=$(genpasswd 16)
vault kv put passwords/DS_ROOT_PASS value=$(genpasswd 16)
vault kv put passwords/KERBEROS_MASTER_SECRET value=$(genpasswd 32)
vault kv put passwords/PKI_ADMIN_PASSWORD value=$(genpasswd 16)
vault kv put passwords/PKI_BACKUP_PASSWORD value=$(genpasswd 16)
vault kv put passwords/PKI_CLIENT_DATABASE_PASSWORD value=$(genpasswd 16)
vault kv put passwords/PKI_CLIENT_PKCS12_PASSWORD value=$(genpasswd 16)
vault kv put passwords/PKI_CLONE_PKCS12_PASSWORD value=$(genpasswd 16)
vault kv put passwords/PKI_REPLICATION_PASSWORD value=$(genpasswd 16)
vault kv put passwords/PKI_SECURITY_DOMAIN_PASSWORD value=$(genpasswd 16)
vault kv put passwords/PKI_SERVER_DATABASE_PASSWORD value=$(genpasswd 16)
vault kv put passwords/PKI_TOKEN_PASSWORD value=$(genpasswd 16)
vault kv put passwords/IDM_ONE_KEYSTORE_PASS value=$(genpasswd 16)
vault kv put passwords/IDM_TWO_KEYSTORE_PASS value=$(genpasswd 16)