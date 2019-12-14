#!/bin/bash

##############################################################################
# Install DogTag
##############################################################################
if [[ $CONTROLLER_FQDN != $IDM_ONE_FQDN ]]; then
  export IDM_ONE_FQDN=$CONTROLLER_FQDN
  export IDM_ONE_IP_ADDRESS=$CONTROLLER_IP_ADDRESS
  export IDM_ONE_KEYSTORE_PASS=$CONTROLLER_KEYSTORE_PASS
fi

# sudo rm -fr /root/.dogtag
# sudo pkidestroy \
#   -s CA \
#   -i ${SSL_PKI_INSTANCE_NAME}

sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_admin_password "${PKI_ADMIN_PASSWORD}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_ajp_port "8009"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_backup_password "${PKI_BACKUP_PASSWORD}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_client_database_password "${PKI_CLIENT_DATABASE_PASSWORD}"
# sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_client_pin "XXXXXXXX"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_client_pkcs12_password "${PKI_CLIENT_PKCS12_PASSWORD}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_clone_pkcs12_password "${PKI_CLONE_PKCS12_PASSWORD}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_ds_bind_dn "cn=Directory Manager"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_ds_hostname "${IDM_ONE_FQDN}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_ds_ldap_port "389"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_ds_ldaps_port "636"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_ds_password "${DS_ROOT_PASS}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_ds_secure_connection "True"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_ds_secure_connection_ca_pem_file "/usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt"
# sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_external_pkcs12_password "XXXXXXXX"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_http_port "8080"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_https_port "8443"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_instance_name "${SSL_PKI_INSTANCE_NAME}"
# sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_one_time_pin "XXXXXXXX"
# sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_pin "XXXXXXXX"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_pkcs12_password "${CA_PASSWORD}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_replication_password "${PKI_REPLICATION_PASSWORD}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_security_domain_hostname "${IDM_ONE_FQDN}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_security_domain_name "${SSL_ORGANIZATION_NAME}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_security_domain_password "${PKI_SECURITY_DOMAIN_PASSWORD}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_server_database_password "${PKI_SERVER_DATABASE_PASSWORD}"
# sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_server_pkcs12_password "XXXXXXXX"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_sslserver_key_algorithm "SHA256withRSA"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_sslserver_key_size "2048"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_sslserver_key_type "rsa"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_sslserver_nickname "sslserver/${IDM_ONE_FQDN}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_sslserver_subject_dn "cn=${IDM_ONE_FQDN},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_subsystem_key_algorithm "SHA256withRSA"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_subsystem_key_size "2048"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_subsystem_key_type "rsa"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_subsystem_nickname "subsystem/${IDM_ONE_FQDN}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_subsystem_subject_dn "cn=Subsystem Certificate,ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_token_password "${PKI_TOKEN_PASSWORD}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg DEFAULT pki_tomcat_server_port "8005"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_admin_email "caadmin@${DNS_DOMAIN}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_admin_name "caadmin"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_admin_nickname "PKI CA Administrator"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_admin_uid "caadmin"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_audit_signing_nickname "${SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ca_signing_csr_path "/root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.csr"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ca_signing_key_algorithm "SHA256withRSA"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ca_signing_key_size "4096"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ca_signing_key_type "rsa"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ca_signing_nickname "${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ca_signing_signing_algorithm "SHA256withRSA"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ca_signing_subject_dn "cn=${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_client_database_purge "False"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ds_base_dn "dc=ca,dc=pki,${DS_SUFFIX}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ds_database "ca"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_external "True"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_external_step_two "False"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ocsp_signing_key_algorithm "SHA256withRSA"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ocsp_signing_key_size "2048"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ocsp_signing_key_type "rsa"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ocsp_signing_nickname "${SSL_INTERMEDIATE_OCSP_TWO_FQDN}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ocsp_signing_signing_algorithm "SHA256withRSA"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_ocsp_signing_subject_dn "cn=${SSL_INTERMEDIATE_OCSP_TWO_FQDN},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_security_domain_name "${SSL_ORGANIZATION_NAME}"
sudo crudini --set /var/lib/openstack/dogtag-step1.cfg CA pki_security_domain_user "caadmin"

sudo pkispawn \
  -s CA \
  -f /var/lib/openstack/dogtag-step1.cfg

export ETCDCTL_ENDPOINTS="https://${CONTROLLER_FQDN}:4100"
ETCD_ADMIN_PASS=$(cat ~/.ETCD_ADMIN_PASS)
sudo cat /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.csr \
| base64 \
| tr -d '\n' \
| etcdctl --username admin:"$ETCD_ADMIN_PASS" mk ephemeral/ca_signing.csr
