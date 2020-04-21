cat << EOF | sudo tee ${OPENSTACK_CONFIGURATION_DIRECTORY}/dogtag-ca.cfg
[DEFAULT]
pki_admin_password = ${PKI_ADMIN_PASSWORD}
pki_backup_password = ${PKI_BACKUP_PASSWORD}
pki_client_database_password = ${PKI_CLIENT_DATABASE_PASSWORD}
# pki_client_pin = XXXXXXXX
pki_client_pkcs12_password = ${PKI_CLIENT_PKCS12_PASSWORD}
pki_clone_pkcs12_password = ${PKI_CLONE_PKCS12_PASSWORD}
pki_ds_password = ${DS_ROOT_PASS}
# pki_external_pkcs12_password = XXXXXXXX
pki_pkcs12_password = ${CA_PASSWORD}
# pki_one_time_pin = XXXXXXXX
# pki_pin = XXXXXXXX
pki_replication_password = ${PKI_REPLICATION_PASSWORD}
pki_security_domain_password = ${PKI_SECURITY_DOMAIN_PASSWORD}
# pki_server_pkcs12_password = XXXXXXXX
pki_token_password = ${PKI_TOKEN_PASSWORD}
pki_ds_bind_dn = cn=Directory Manager
pki_ds_hostname = ${CONTROLLER_FQDN}
pki_ds_ldap_port = 389
pki_ds_ldaps_port = 636
pki_ds_secure_connection_ca_pem_file = /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt
pki_ds_secure_connection = True
pki_http_port = 8080
pki_https_port = 8443
pki_instance_name = pki-tomcat
pki_sslserver_nickname = sslserver/${CONTROLLER_FQDN}
pki_subsystem_nickname = subsystem/${CONTROLLER_FQDN}
pki_server_database_password = ${PKI_SERVER_DATABASE_PASSWORD}
pki_ajp_port = 8009
pki_security_domain_hostname = ${CONTROLLER_FQDN}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_tomcat_server_port = 8005

[CA]
pki_admin_email = caadmin@${DNS_DOMAIN}
pki_admin_name = caadmin
pki_admin_nickname = PKI CA Administrator
pki_admin_uid = caadmin
pki_audit_signing_nickname = ${SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME}
pki_ca_signing_key_algorithm = SHA256withRSA
pki_ca_signing_key_size = 4096
pki_ca_signing_key_type = rsa
pki_ca_signing_nickname = ${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME}
pki_ca_signing_signing_algorithm = SHA256withRSA
pki_ca_signing_subject_dn = cn=${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_client_database_purge = False
pki_ds_base_dn = dc=ca,dc=pki,${DS_SUFFIX}
pki_ds_database = ca
pki_ocsp_signing_nickname = ${SSL_INTERMEDIATE_OCSP_TWO_FQDN}
pki_security_domain_user = caadmin
EOF
sudo pkispawn -s CA -f ${OPENSTACK_CONFIGURATION_DIRECTORY}/dogtag-ca.cfg -vv

cat << EOF | sudo tee ${OPENSTACK_CONFIGURATION_DIRECTORY}/dogtag-kra.cfg

[KRA]
pki_admin_cert_file=/root/.dogtag/pki-tomcat/ca_admin.cert
pki_admin_email=kraadmin@${DNS_DOMAIN}
pki_admin_name=kraadmin
pki_admin_nickname=PKI KRA Administrator
pki_admin_password = ${PKI_ADMIN_PASSWORD}
pki_admin_uid=kraadmin
pki_backup_password = ${PKI_BACKUP_PASSWORD}
pki_client_database_password = ${PKI_CLIENT_DATABASE_PASSWORD}
pki_client_database_purge=False
pki_client_pkcs12_password = ${PKI_CLIENT_PKCS12_PASSWORD}
pki_clone_pkcs12_password = ${PKI_CLONE_PKCS12_PASSWORD}
pki_ds_bind_dn = cn=Directory Manager
pki_ds_base_dn = dc=kra,${DS_SUFFIX}
pki_ds_database = kra
pki_ds_password = ${DS_ROOT_PASS}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_user = caadmin
pki_security_domain_password = ${PKI_SECURITY_DOMAIN_PASSWORD}
pki_token_password = ${PKI_TOKEN_PASSWORD}
pki_https_port=8443
pki_http_port=8080
pki_ajp_port=8009
pki_tomcat_server_port=8005
pki_security_domain_hostname = ${CONTROLLER_FQDN}
#pki_security_domain_https_port=8373
EOF

sudo pkispawn -s KRA -f ${OPENSTACK_CONFIGURATION_DIRECTORY}/dogtag-kra.cfg
https://jack.se.lemche.net:8443/ca
