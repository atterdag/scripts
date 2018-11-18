#!/bin/sh

##############################################################################
# Install Keystone on Controller host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet keystone

cat > /var/lib/openstack/keystone.sql << EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_DBPASS}';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_DBPASS}';
exit
EOF
mysql --user=root --password="${ROOT_DBPASS}" < /var/lib/openstack/keystone.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=keystone --password=$KEYSTONE_DBPASS keystone

mv /etc/keystone/keystone.conf /etc/keystone/keystone.conf.org
cat > /etc/keystone/keystone.conf << EOF
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
chmod 0640 /etc/keystone/keystone.conf
chown keystone:keystone /etc/keystone/keystone.conf

mkdir /etc/keystone/ssl/private

cp \
  ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.crt \
  /etc/keystone/ssl/certs/keystone.pem
cp \
  ${SSL_CA_DIR}/private/${CONTROLLER_FQDN}.key \
  /etc/keystone/ssl/private/keystonekey.pem
cp \
  ${SSL_CA_DIR}/certs/ca.crt \
  /etc/keystone/ssl/certs/ca.pem
cp \
  ${SSL_CA_DIR}/private/ca.key \
  /etc/keystone/ssl/private/cakey.pem
chown -R keystone:keystone /etc/keystone/ssl

cat >> /etc/apache2/sites-available/wsgi-keystone.conf << EOT
SSLCertificateFile    /etc/ssl/certs/${CONTROLLER_FQDN}.crt
SSLCertificateKeyFile /etc/ssl/private/${CONTROLLER_FQDN}.key
EOT

sed -i 's|</VirtualHost>|\tSSLEngine on\n</VirtualHost>|' \
  /etc/apache2/sites-available/wsgi-keystone.conf

systemctl restart apache2

su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup \
  --keystone-user keystone \
  --keystone-group keystone
keystone-manage credential_setup \
  --keystone-user keystone \
  --keystone-group keystone
keystone-manage bootstrap \
  --bootstrap-password $ADMIN_PASS \
  --bootstrap-admin-url https://${CONTROLLER_FQDN}:35357/v3/ \
  --bootstrap-internal-url https://${CONTROLLER_FQDN}:35357/v3/ \
  --bootstrap-public-url https://${CONTROLLER_FQDN}:5000/v3/ \
  --bootstrap-region-id RegionOne

export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=https://${CONTROLLER_FQDN}:35357/v3
export OS_IDENTITY_API_VERSION=3

openstack project create \
  --domain default \
  --description "Service Project" \
  service
openstack project create \
  --domain default \
  --description "Demo Project" \
  demo
openstack user create \
  --domain default \
  --password $DEMO_PASS \
  demo
openstack role create \
  user
openstack role add \
  --project demo \
  --user demo \
  user

unset OS_AUTH_URL OS_PASSWORD
openstack \
  --os-auth-url https://${CONTROLLER_FQDN}:35357/v3 \
  --os-project-domain-name Default \
  --os-user-domain-name Default \
  --os-project-name admin \
  --os-password $ADMIN_PASS \
  --os-username admin \
  token \
    issue
openstack \
  --os-auth-url https://${CONTROLLER_FQDN}:35357/v3 \
  --os-project-domain-name Default \
  --os-user-domain-name Default \
  --os-project-name demo \
  --os-username demo \
  --os-password $DEMO_PASS \
  token \
    issue

cat > /var/lib/openstack/admin-openrc << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=https://${CONTROLLER_FQDN}:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
cat > /var/lib/openstack/demo-openrc << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=$DEMO_PASS
export OS_AUTH_URL=https://${CONTROLLER_FQDN}:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
source /var/lib/openstack/admin-openrc
openstack token issue
