#!/bin/bash

##############################################################################
# Configure Keystone on Controller host
##############################################################################
sudo crudini --set /etc/keystone/keystone.conf identity domain_specific_drivers_enabled "True"
sudo crudini --set /etc/keystone/keystone.conf identity domain_config_dir "/etc/keystone/domains"

sudo systemctl restart \
  apache2

sudo mkdir --parents \
  /etc/keystone/domains
sudo chmod 0700 \
  /etc/keystone/domains
sudo chown keystone:keystone \
  /etc/keystone/domains

sudo crudini --set /etc/keystone/domains/keystone.ldap.conf identity driver "ldap"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap url "ldap://${IDM_ONE_FQDN}:389"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap user "cn=Directory Manager"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap password "${DS_ROOT_PASS}"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap suffix "${DS_SUFFIX}"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap query_scope "one"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap page_size "0"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap alias_dereferencing "default"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap debug_level "0"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap user_tree_dn "ou=People,${DS_SUFFIX}"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap user_objectclass "inetOrgPerson"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap user_id_attribute "nsUniqueId"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap user_name_attribute "uid"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap user_description_attribute "description"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap user_mail_attribute "mail"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap user_pass_attribute "userPassword"
#sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap user_default_project_id_attribute "<TBD>"
#sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap user_additional_attribute_mapping
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap group_tree_dn "ou=Groups,${DS_SUFFIX}"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap group_objectclass "groupOfNames"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap group_id_attribute "nsUniqueId"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap group_name_attribute "cn"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap group_member_attribute "member"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap group_desc_attribute "description"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap tls_cacertfile "/etc/ssl/certs/ca-certificates.crt"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap use_tls "true"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap tls_req_cert "demand"
#sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap connection_timeout "-1"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap use_pool "true"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap pool_size "10"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap pool_retry_max "3"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap pool_retry_delay "0.1"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap pool_connection_timeout "-1"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap pool_connection_lifetime "600"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap use_auth_pool "true"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap auth_pool_size "100"
sudo crudini --set /etc/keystone/domains/keystone.ldap.conf ldap auth_pool_connection_lifetime "60"

sudo chmod 0640 \
  /etc/keystone/domains/keystone.ldap.conf
sudo chown keystone:keystone \
  /etc/keystone/domains/keystone.ldap.conf

openstack domain create \
  --description "Domain for users, and groups from LDAP" \
  ldap
