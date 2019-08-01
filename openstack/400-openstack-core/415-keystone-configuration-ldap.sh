#!/bin/sh

##############################################################################
# Configure Keystone on Controller host
##############################################################################
sudo crudini --set /etc/keystone/keystone.conf identity domain_specific_drivers_enabled True
sudo crudini --set /etc/keystone/keystone.conf identity domain_config_dir /etc/keystone/domains
#sudo crudini --set /etc/keystone/keystone.conf identity domain_configurations_from_database True

sudo systemctl restart \
  apache2

sudo mkdir --parents /etc/keystone/domains
sudo chmod 0700 /etc/keystone/domains
sudo chown keystone:keystone /etc/keystone/domains

cat << EOF | sudo tee /etc/keystone/domains/keystone.ldap.conf
[identity]
driver = ldap

[ldap]
url = ldap://${IDM_ONE_FQDN}:389
user = cn=Directory Manager
password = ${DS_ROOT_PASS}
suffix = ${DS_SUFFIX}
query_scope = one
page_size = 0
alias_dereferencing = default
debug_level = 0
user_tree_dn = ou=People,${DS_SUFFIX}
user_objectclass = inetOrgPerson
user_id_attribute = nsUniqueId
user_name_attribute = uid
user_description_attribute = description
user_mail_attribute = mail
user_pass_attribute = userPassword
#user_default_project_id_attribute = TBD
#user_additional_attribute_mapping =
group_tree_dn = ou=Groups,${DS_SUFFIX}
group_objectclass = groupOfNames
group_id_attribute = nsUniqueId
group_name_attribute = cn
group_member_attribute = member
group_desc_attribute = description
tls_cacertfile = /etc/ssl/certs/ca-certificates.crt
use_tls = true
tls_req_cert = demand
#connection_timeout = -1
use_pool = true
pool_size = 10
pool_retry_max = 3
pool_retry_delay = 0.1
pool_connection_timeout = -1
pool_connection_lifetime = 600
use_auth_pool = true
auth_pool_size = 100
auth_pool_connection_lifetime = 60
EOF
sudo chmod 0640 /etc/keystone/domains/keystone.ldap.conf
sudo chown keystone:keystone /etc/keystone/domains/keystone.ldap.conf

openstack domain create \
  --description "Domain for users, and groups from LDAP" \
  ldap

# sudo su \
#   --shell /bin/sh \
#   --command "keystone-manage domain_config_upload --domain-name ldap" \
#   keystone
