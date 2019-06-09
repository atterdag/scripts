#!/bin/sh

##############################################################################
# Install Barbican on Controller host
##############################################################################

sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  barbican-api \
  barbican-keystone-listener \
  barbican-worker

cat << EOF | sudo tee /var/lib/openstack/barbican.sql
CREATE DATABASE barbican;
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'localhost' IDENTIFIED BY '${BARBICAN_DBPASS}';
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'%' IDENTIFIED BY '${BARBICAN_DBPASS}';
EOF
sudo chmod 0600 /var/lib/openstack/barbican.sql
sudo cat /var/lib/openstack/barbican.sql | sudo mysql --host=localhost --user=root
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=barbican --password=$BARBICAN_DBPASS barbican

openstack user create \
  --domain default \
  --password $BARBICAN_PASS \
  barbican
openstack role add \
  --project service \
  --user barbican \
  admin
openstack role create \
  creator
openstack role add \
  --project service \
  --user barbican \
  creator
openstack service create \
  --name barbican \
  --description "Key Manager" \
  key-manager
openstack endpoint create \
  --region RegionOne \
  key-manager public http://${CONTROLLER_FQDN}:9311
openstack endpoint create \
  --region RegionOne \
  key-manager internal http://${CONTROLLER_FQDN}:9311
openstack endpoint create \
  --region RegionOne \
  key-manager admin http://${CONTROLLER_FQDN}:9311

sudo usermod -a -G ssl-cert barbican

sudo mv /etc/barbican/barbican.conf /etc/barbican/barbican.conf.org
cat << EOF | sudo tee /etc/barbican/barbican.conf
[DEFAULT]
bind_host = 0.0.0.0
bind_port = 9311
host_href = http://${CONTROLLER_FQDN}:9311
backlog = 4096
max_allowed_secret_in_bytes = 10000
max_allowed_request_size_in_bytes = 1000000
sql_connection = mysql+pymysql://barbican:${BARBICAN_DBPASS}@${CONTROLLER_FQDN}/barbican
sql_idle_timeout = 3600
default_limit_paging = 10
max_limit_paging = 100
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}

[oslo_messaging_rabbit]

[oslo_messaging_notifications]

[oslo_policy]
policy_file=/etc/barbican/policy.json
policy_default_rule=default

[queue]
enable = False
namespace = 'barbican'
topic = 'barbican.workers'
version = '1.1'
server_name = 'barbican.queue'
asynchronous_workers = 1

[retry_scheduler]
initial_delay_seconds = 10.0
periodic_interval_max_seconds = 10.0

[quotas]
quota_secrets = -1
quota_orders = -1
quota_containers = -1
quota_consumers = -1
quota_cas = -1

[keystone_authtoken]
auth_uri = https://${CONTROLLER_FQDN}:5000
auth_url = https://${CONTROLLER_FQDN}:5000
certfile = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
keyfile = /etc/ssl/private/${CONTROLLER_FQDN}.key
cafile = /etc/ssl/certs/${SSL_CA_NAME}.pem
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = barbican
password = $BARBICAN_PASS
auth_type = password

[keystone_notifications]
enable = True
control_exchange = 'openstack'
topic = 'notifications'
allow_requeue = False
version = '1.0'
thread_pool_size = 10

[secretstore]
namespace = barbican.secretstore.plugin
enabled_secretstore_plugins = store_crypto

[crypto]
namespace = barbican.crypto.plugin
enabled_crypto_plugins = simple_crypto

[simple_crypto_plugin]
kek = '${BARBICAN_KEK}'

[dogtag_plugin]

[p11_crypto_plugin]

[kmip_plugin]

[certificate]
namespace = barbican.certificate.plugin
enabled_certificate_plugins = simple_certificate
enabled_certificate_plugins = ${SIMPLE_CRYPTO_CA}_ca

[certificate_event]
namespace = barbican.certificate.event.plugin
enabled_certificate_event_plugins = simple_certificate_event

[${SIMPLE_CRYPTO_CA}_ca_plugin]
ca_cert_path = /etc/barbican/${SIMPLE_CRYPTO_CA}-ca.crt
ca_cert_key_path = /etc/barbican/${SIMPLE_CRYPTO_CA}-ca.key
ca_cert_chain_path = /etc/barbican/${SIMPLE_CRYPTO_CA}-ca.chain
ca_cert_pkcs7_path = /etc/barbican/${SIMPLE_CRYPTO_CA}-ca.p7b
subca_cert_key_directory=/etc/barbican/${SIMPLE_CRYPTO_CA}-cas

[cors]

[cors.subdomain]

EOF
sudo chmod 0640 /etc/barbican/barbican.conf
sudo chown barbican:barbican /etc/barbican/barbican.conf

sudo su -s /bin/sh -c "barbican-manage db current" barbican

sudo systemctl restart \
  barbican-api \
  barbican-worker \
  barbican-keystone-listener
