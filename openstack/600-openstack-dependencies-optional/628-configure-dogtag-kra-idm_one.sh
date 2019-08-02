#!/bin/bash

##############################################################################
# Install DogTag
##############################################################################
cat << EOF | sudo tee /var/lib/openstack/dogtag-kra.cfg
[DEFAULT]
pki_admin_password = ${PKI_ADMIN_PASSWORD}
pki_ajp_port = 8009
pki_backup_password = ${PKI_BACKUP_PASSWORD}
pki_client_database_password = ${PKI_CLIENT_DATABASE_PASSWORD}
# pki_client_pin = XXXXXXXX
pki_client_pkcs12_password = ${PKI_CLIENT_PKCS12_PASSWORD}
pki_clone_pkcs12_password = ${PKI_CLONE_PKCS12_PASSWORD}
pki_ds_bind_dn = cn=Directory Manager
pki_ds_hostname = ${IDM_ONE_FQDN}
pki_ds_ldap_port = 389
pki_ds_ldaps_port = 636
pki_ds_password = ${DS_ROOT_PASS}
pki_ds_secure_connection = True
pki_ds_secure_connection_ca_pem_file = /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt
# pki_external_pkcs12_password = XXXXXXXX
pki_http_port = 8080
pki_https_port = 8443
pki_instance_name = ${SSL_PKI_INSTANCE_NAME}
# pki_one_time_pin = XXXXXXXX
# pki_pin = XXXXXXXX
pki_pkcs12_password = ${CA_PASSWORD}
pki_replication_password = ${PKI_REPLICATION_PASSWORD}
pki_security_domain_hostname = ${IDM_ONE_FQDN}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_password = ${PKI_SECURITY_DOMAIN_PASSWORD}
pki_server_database_password = ${PKI_SERVER_DATABASE_PASSWORD}
# pki_server_pkcs12_password = XXXXXXXX
pki_sslserver_key_algorithm=SHA256withRSA
pki_sslserver_key_size=2048
pki_sslserver_key_type=rsa
pki_sslserver_nickname = sslserver/${IDM_ONE_FQDN}
pki_sslserver_subject_dn=cn=${IDM_ONE_FQDN},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_subsystem_key_algorithm=SHA256withRSA
pki_subsystem_key_size=2048
pki_subsystem_key_type=rsa
pki_subsystem_nickname = subsystem/${IDM_ONE_FQDN}
pki_subsystem_subject_dn=cn=Subsystem Certificate,ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_token_password = ${PKI_TOKEN_PASSWORD}
pki_tomcat_server_port = 8005

[KRA]
pki_admin_cert_file=/root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_admin.cert
pki_admin_email=kraadmin@${DNS_DOMAIN}
pki_admin_name=kraadmin
pki_admin_nickname=PKI KRA Administrator
pki_admin_uid=kraadmin
pki_client_database_purge=False
pki_ds_base_dn=dc=kra,dc=pki,${DS_SUFFIX}
pki_ds_database=kra
EOF
sudo pkispawn \
  -s KRA \
  -f /var/lib/openstack/dogtag-kra.cfg
