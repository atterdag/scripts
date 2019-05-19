#!/bin/sh

##############################################################################
# Install Keystone on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet keystone libapache2-mod-wsgi

cat << EOF | sudo tee /var/lib/openstack/keystone.sql
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_DBPASS}';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_DBPASS}';
EXIT
EOF
sudo chmod 0600 /var/lib/openstack/keystone.sql
sudo cat /var/lib/openstack/keystone.sql | sudo mysql --user=root --password="${ROOT_DBPASS}"
sudo mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=keystone --password=$KEYSTONE_DBPASS keystone

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

for i in private certs; do sudo mkdir -p /etc/keystone/ssl/$i; done

sudo cp \
  ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.crt \
  /etc/keystone/ssl/certs/keystone.pem
sudo cp \
  ${SSL_CA_DIR}/private/${CONTROLLER_FQDN}.key \
  /etc/keystone/ssl/private/keystonekey.pem
sudo cp \
  ${SSL_CA_DIR}/certs/ca.crt \
  /etc/keystone/ssl/certs/ca.pem
sudo cp \
  ${SSL_CA_DIR}/private/ca.key \
  /etc/keystone/ssl/private/cakey.pem
sudo chown -R keystone:keystone /etc/keystone/ssl

cat << EOF | sudo tee -a /etc/apache2/sites-available/keystone.conf
SSLCertificateFile    /etc/ssl/certs/${CONTROLLER_FQDN}.crt
SSLCertificateKeyFile /etc/ssl/private/${CONTROLLER_FQDN}.key
EOF

sudo \
  sed -i 's|</VirtualHost>|\tSSLEngine on\n</VirtualHost>|' \
  /etc/apache2/sites-available/keystone.conf

sudo systemctl restart apache2

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

export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=https://${CONTROLLER_FQDN}:5000/v3
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
  --os-auth-url https://${CONTROLLER_FQDN}:5000/v3 \
  --os-project-domain-name Default \
  --os-user-domain-name Default \
  --os-project-name admin \
  --os-password $ADMIN_PASS \
  --os-username admin \
  token \
    issue
openstack \
  --os-auth-url https://${CONTROLLER_FQDN}:5000/v3 \
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
export OS_AUTH_URL=https://${CONTROLLER_FQDN}:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
cat > /var/lib/openstack/demo-openrc << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=$DEMO_PASS
export OS_AUTH_URL=https://${CONTROLLER_FQDN}:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
source /var/lib/openstack/admin-openrc
openstack token issue
