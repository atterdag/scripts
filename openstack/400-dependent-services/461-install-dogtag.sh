#!/bin/sh

##############################################################################
# Install DogTag
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install \
  pki-ca \
  pki-kra \
  liboscache-java \
  libstax-java

sudo openssl ca \
  -config ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/openssl.cnf \
  -revoke ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
  -passin "pass:${CA_PASSWORD}"
sudo rm -fr /root/.dogtag
sudo pkidestroy \
  -s CA \
  -i ${SSL_PKI_INSTANCE_NAME}

cat << EOF | sudo tee /var/lib/openstack/dogtag-step1.cfg
[DEFAULT]
pki_admin_password = ${PKI_ADMIN_PASSWORD}
pki_ajp_port = 8009
pki_backup_password = ${PKI_BACKUP_PASSWORD}
pki_client_database_password = ${PKI_CLIENT_DATABASE_PASSWORD}
# pki_client_pin = XXXXXXXX
pki_client_pkcs12_password = ${PKI_CLIENT_PKCS12_PASSWORD}
pki_clone_pkcs12_password = ${PKI_CLONE_PKCS12_PASSWORD}
pki_ds_bind_dn = cn=Directory Manager
pki_ds_hostname = ${CONTROLLER_FQDN}
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
pki_security_domain_hostname = ${CONTROLLER_FQDN}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_password = ${PKI_SECURITY_DOMAIN_PASSWORD}
pki_server_database_password = ${PKI_SERVER_DATABASE_PASSWORD}
# pki_server_pkcs12_password = XXXXXXXX
pki_sslserver_key_algorithm=SHA256withRSA
pki_sslserver_key_size=2048
pki_sslserver_key_type=rsa
pki_sslserver_nickname = sslserver/${CONTROLLER_FQDN}
pki_sslserver_subject_dn=cn=${CONTROLLER_FQDN},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_subsystem_key_algorithm=SHA256withRSA
pki_subsystem_key_size=2048
pki_subsystem_key_type=rsa
pki_subsystem_nickname = subsystem/${CONTROLLER_FQDN}
pki_subsystem_subject_dn=cn=Subsystem Certificate,ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_token_password = ${PKI_TOKEN_PASSWORD}
pki_tomcat_server_port = 8005

[CA]
pki_admin_email = caadmin@${DNS_DOMAIN}
pki_admin_name = caadmin
pki_admin_nickname = PKI CA Administrator
pki_admin_uid = caadmin
pki_audit_signing_nickname=${SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME}
pki_ca_signing_csr_path = /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.csr
pki_ca_signing_key_algorithm = SHA256withRSA
pki_ca_signing_key_size = 4096
pki_ca_signing_key_type = rsa
pki_ca_signing_nickname = ${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME}
pki_ca_signing_signing_algorithm = SHA256withRSA
pki_ca_signing_subject_dn = cn=${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_client_database_purge = False
pki_ds_base_dn = dc=ca,dc=pki,${DS_SUFFIX}
pki_ds_database = ca
pki_external = True
pki_external_step_two = False
pki_ocsp_signing_key_algorithm=SHA256withRSA
pki_ocsp_signing_key_size=2048
pki_ocsp_signing_key_type=rsa
pki_ocsp_signing_nickname = ${SSL_INTERMEDIATE_OCSP_TWO_FQDN}
pki_ocsp_signing_signing_algorithm=SHA256withRSA
pki_ocsp_signing_subject_dn=cn=${SSL_INTERMEDIATE_OCSP_TWO_FQDN},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_user = caadmin

EOF
sudo pkispawn \
  -s CA \
  -f /var/lib/openstack/dogtag-step1.cfg

sudo cp \
  -f \
  /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.csr \
  ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.csr

sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/openssl.cnf \
  -days 3650 \
  -extensions v3_intermediate_ca \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private/${SSL_ROOT_CA_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
  -passin pass:${CA_PASSWORD} \
  -policy policy_anything

sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
  -out /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/${SSL_ROOT_CA_STRICT_NAME}.crt
sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
  -out /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.crt

# Update OS truststore
sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
  -out /usr/local/share/ca-certificates/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt
sudo update-ca-certificates \
  --verbose \
  --fresh

# sudo certutil \
#   -A \
#   -d /etc/pki/${SSL_PKI_INSTANCE_NAME}/alias/ \
#   -n "${SSL_ROOT_CA_COMMON_NAME}" \
#   -t "C,," \
#   -i /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt

cat << EOF | sudo tee /var/lib/openstack/dogtag-step2.cfg
[DEFAULT]
pki_admin_password = ${PKI_ADMIN_PASSWORD}
pki_ajp_port = 8009
pki_backup_password = ${PKI_BACKUP_PASSWORD}
pki_client_database_password = ${PKI_CLIENT_DATABASE_PASSWORD}
# pki_client_pin = XXXXXXXX
pki_client_pkcs12_password = ${PKI_CLIENT_PKCS12_PASSWORD}
pki_clone_pkcs12_password = ${PKI_CLONE_PKCS12_PASSWORD}
pki_ds_bind_dn = cn=Directory Manager
pki_ds_hostname = ${CONTROLLER_FQDN}
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
pki_security_domain_hostname = ${CONTROLLER_FQDN}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_password = ${PKI_SECURITY_DOMAIN_PASSWORD}
pki_server_database_password = ${PKI_SERVER_DATABASE_PASSWORD}
# pki_server_pkcs12_password = XXXXXXXX
pki_sslserver_key_algorithm=SHA256withRSA
pki_sslserver_key_size=2048
pki_sslserver_key_type=rsa
pki_sslserver_nickname = sslserver/${CONTROLLER_FQDN}
pki_sslserver_subject_dn=cn=${CONTROLLER_FQDN},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_subsystem_key_algorithm=SHA256withRSA
pki_subsystem_key_size=2048
pki_subsystem_key_type=rsa
pki_subsystem_nickname = subsystem/${CONTROLLER_FQDN}
pki_subsystem_subject_dn=cn=Subsystem Certificate,ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_token_password = ${PKI_TOKEN_PASSWORD}
pki_tomcat_server_port = 8005

[CA]
pki_admin_email = caadmin@${DNS_DOMAIN}
pki_admin_name = caadmin
pki_admin_nickname = PKI CA Administrator
pki_admin_uid = caadmin
pki_audit_signing_nickname=${SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME}
pki_ca_signing_cert_path = /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.crt
pki_ca_signing_csr_path = /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.csr
pki_ca_signing_key_algorithm = SHA256withRSA
pki_ca_signing_key_size = 4096
pki_ca_signing_key_type = rsa
pki_ca_signing_nickname = ${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME}
pki_ca_signing_signing_algorithm = SHA256withRSA
pki_ca_signing_subject_dn = cn=${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_cert_chain_nickname = ${SSL_ROOT_CA_COMMON_NAME}
pki_cert_chain_path = /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/${SSL_ROOT_CA_STRICT_NAME}.crt
pki_client_database_purge = False
pki_ds_base_dn = dc=ca,dc=pki,${DS_SUFFIX}
pki_ds_database = ca
pki_external = True
pki_external_step_two = True
pki_ocsp_signing_key_algorithm=SHA256withRSA
pki_ocsp_signing_key_size=2048
pki_ocsp_signing_key_type=rsa
pki_ocsp_signing_nickname = ${SSL_INTERMEDIATE_OCSP_TWO_FQDN}
pki_ocsp_signing_signing_algorithm=SHA256withRSA
pki_ocsp_signing_subject_dn=cn=${SSL_INTERMEDIATE_OCSP_TWO_FQDN},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_user = caadmin
EOF
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
pki_ds_hostname = ${CONTROLLER_FQDN}
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
pki_security_domain_hostname = ${CONTROLLER_FQDN}
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
