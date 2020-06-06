#!/bin/bash

##############################################################################
# Set passwords in etcd on controller node
##############################################################################
export ETCDCTL_ENDPOINTS="http://localhost:2379"
source /etc/profile.d/genpasswd.sh
if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read ETCD_ADMIN_PASS; fi
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/ADMIN_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/BARBICAN_DBPASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/BARBICAN_KEK $(echo $(genpasswd 32) | base64)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/BARBICAN_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/CA_PASSWORD $(genpasswd 32)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/CINDER_DBPASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/CINDER_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/COMPUTE_KEYSTORE_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/CONTROLLER_KEYSTORE_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/DASH_DBPASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/DEMO_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/DESIGNATE_DBPASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/DESIGNATE_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/DS_ADMIN_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/DS_ROOT_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/ETCD_ONE_KEYSTORE_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/ETCD_TWO_KEYSTORE_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/GLANCE_DBPASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/GLANCE_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/IDM_ONE_KEYSTORE_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/IDM_TWO_KEYSTORE_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/KERBEROS_MASTER_SECRET $(genpasswd 32)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/KEYSTONE_DBPASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/METADATA_SECRET $(genpasswd 32)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/NEUTRON_DBPASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/NEUTRON_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/NOVA_DBPASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/NOVA_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/OCTAVIA_DBPASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/OCTAVIA_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/PKI_ADMIN_PASSWORD $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/PKI_BACKUP_PASSWORD $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/PKI_CLIENT_DATABASE_PASSWORD $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/PKI_CLIENT_PKCS12_PASSWORD $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/PKI_CLONE_PKCS12_PASSWORD $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/PKI_REPLICATION_PASSWORD $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/PKI_SECURITY_DOMAIN_PASSWORD $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/PKI_SERVER_DATABASE_PASSWORD $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/PKI_TOKEN_PASSWORD $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/PLACEMENT_DBPASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/PLACEMENT_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/RABBIT_ADMIN_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/RABBIT_PASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/ROOT_DBPASS $(genpasswd 16)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/SSL_OCTAVIA_CLIENT_CA_PASSWORD $(genpasswd 32)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/SSL_OCTAVIA_CLIENT_CERT_KEYSTORE_PASS $(genpasswd 32)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/SSL_OCTAVIA_SERVER_CA_KEYSTORE_PASS $(genpasswd 32)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/SSL_OCTAVIA_SERVER_CA_PASSWORD $(genpasswd 32)
