#!/bin/sh

##############################################################################
# Configure Keystone on Controller host
##############################################################################
sudo mv /etc/keystone/keystone.conf /etc/keystone/keystone.conf.org
cat << EOF | sudo tee /etc/keystone/keystone.conf
[DEFAULT]
log_file = keystone.log
log_dir = /var/log/keystone

[assignment]

[auth]

[cache]

[catalog]
template_file = /etc/keystone/default_catalog.templates

[cors]

[cors.subdomain]

[credential]

[database]
connection = mysql+pymysql://keystone:${KEYSTONE_DBPASS}@${CONTROLLER_FQDN}/keystone

[domain_config]

[endpoint_filter]

[endpoint_policy]

[eventlet_server]

[extra_headers]
Distribution = Ubuntu

[federation]

[fernet_tokens]

[identity]
driver = sql
domain_specific_drivers_enabled = True
domain_config_dir = /etc/keystone/domains
domain_specific_drivers_enabled = True
domain_configurations_from_database = True

[identity_mapping]

[kvs]

[ldap]

[matchmaker_redis]

[memcache]

[oauth1]

[os_inherit]

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[paste_deploy]

[policy]

[profiler]

[resource]

[revoke]

[role]

[saml]

[security_compliance]

[shadow_users]

[signing]

[token]
provider = fernet

[tokenless_auth]

[trust]

EOF
sudo chmod 0640 /etc/keystone/keystone.conf
sudo chown keystone:keystone /etc/keystone/keystone.conf

sudo mkdir --parents /etc/keystone/domains
cat << EOF | sudo tee /etc/keystone/domains/keystone_ldap.conf
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
user_id_attribute = uid
user_name_attribute = sn
user_description_attribute = description
user_mail_attribute = mail
user_pass_attribute = userPassword
group_tree_dn = ou=Groups,${DS_SUFFIX}
group_objectclass = groupOfNames
group_id_attribute = cn
group_name_attribute = cn
group_member_attribute = member
group_desc_attribute = description
tls_cacertfile = /etc/ssl/certs/ca-certificates.crt
use_tls = true
tls_req_cert = demand
connection_timeout = -1
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
sudo chmod 0640 /etc/keystone/domains/keystone_ldap.conf
sudo chown keystone:keystone /etc/keystone/domains/keystone_ldap.conf

sudo su -s /bin/sh -c "keystone-manage domain_config_upload --all" keystone
sudo su -s /bin/sh -c "keystone-manage db_sync" keystone
sudo keystone-manage fernet_setup \
  --keystone-user keystone \
  --keystone-group keystone
sudo keystone-manage credential_setup \
  --keystone-user keystone \
  --keystone-group keystone
sudo keystone-manage bootstrap \
  --bootstrap-password $ADMIN_PASS \
  --bootstrap-admin-url https://${CONTROLLER_FQDN}:5000/v3/ \
  --bootstrap-internal-url https://${CONTROLLER_FQDN}:5000/v3/ \
  --bootstrap-public-url https://${CONTROLLER_FQDN}:5000/v3/ \
  --bootstrap-region-id RegionOne
