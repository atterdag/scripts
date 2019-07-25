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
