#!/bin/sh

##############################################################################
# Install DogTag
##############################################################################
sudo pkispawn \
  -s CA \
  -f /var/lib/openstack/dogtag-step2.cfg

sudo certutil \
  -L \
  -d /etc/pki/${SSL_PKI_INSTANCE_NAME}/alias
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-init
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-cert-import \
  --ca-cert /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/${SSL_ROOT_CA_STRICT_NAME}.crt
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-cert-import \
  "${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME}" \
  --ca-cert /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.crt
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-cert-import \
  --pkcs12 /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_admin_cert.p12 \
  --pkcs12-password-file /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca/pkcs12_password.conf
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  -n caadmin ca-user-show caadmin

cat << EOF | sudo tee /var/lib/openstack/dogtag-kra.cfg
[DEFAULT]
pki_admin_password = ${PKI_ADMIN_PASSWORD}
pki_backup_password = ${PKI_BACKUP_PASSWORD}
pki_client_database_password = ${PKI_CLIENT_DATABASE_PASSWORD}
pki_client_pkcs12_password = ${PKI_CLIENT_PKCS12_PASSWORD}
pki_clone_pkcs12_password = ${PKI_CLONE_PKCS12_PASSWORD}
pki_ds_bind_dn = cn=Directory Manager
pki_ds_hostname = ${IDM_ONE_FQDN}
pki_ds_ldap_port = 389
pki_ds_ldaps_port = 636
pki_ds_password = ${DS_ROOT_PASS}
pki_ds_remove_data = True
pki_ds_secure_connection_ca_pem_file = /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt
pki_ds_secure_connection = True
pki_http_port = 8080
pki_https_port = 8443
pki_instance_name = ${SSL_PKI_INSTANCE_NAME}
pki_replication_password = ${PKI_REPLICATION_PASSWORD}
pki_security_domain_hostname = ${IDM_ONE_FQDN}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_password = ${PKI_SECURITY_DOMAIN_PASSWORD}
pki_security_domain_user = caadmin
pki_server_database_password = ${PKI_SERVER_DATABASE_PASSWORD}
pki_token_password = ${PKI_TOKEN_PASSWORD}

[Tomcat]
pki_ajp_port = 8009
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
