#!/bin/bash

##############################################################################
# Install Barbican on Controller host
##############################################################################
sudo mv /etc/barbican/barbican.conf /etc/barbican/barbican.conf.org
cat << EOF | sudo tee /etc/barbican/barbican.conf
[DEFAULT]
sql_connection = mysql+pymysql://barbican:${BARBICAN_DBPASS}@${CONTROLLER_FQDN}/barbican
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}

[certificate]
namespace = barbican.certificate.plugin
enabled_certificate_plugins = dogtag

[certificate_event]

[cors]

[crypto]

[dogtag_plugin]
pem_path = /etc/barbican/kra-agent.pem
dogtag_host = ${IDM_ONE_FQDN}
dogtag_port = 8443
nss_db_path = '/etc/barbican/alias'
nss_db_path_ca = '/etc/barbican/alias-ca'
nss_password = ${PKI_SERVER_DATABASE_PASSWORD}
simple_cmc_profile = 'caOtherCert'
ca_expiration_time = 1
plugin_working_dir = '/etc/barbican/dogtag'

[keystone_authtoken]
www_authenticate_uri = https://${CONTROLLER_FQDN}:5000
auth_url = https://${CONTROLLER_FQDN}:5000
certfile = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
keyfile = /etc/ssl/private/${CONTROLLER_FQDN}.key
cafile = /etc/ssl/certs/ca-certificates.crt
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = barbican
password = $BARBICAN_PASS
auth_type = password

[keystone_notifications]

[kmip_plugin]

[matchmaker_redis]

[oslo_messaging_amqp]

[oslo_messaging_kafka]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[p11_crypto_plugin]

[queue]

[quotas]

[retry_scheduler]

[secretstore]
namespace = barbican.secretstore.plugin
enabled_secretstore_plugins = dogtag_crypto

[simple_crypto_plugin]

[snakeoil_ca_plugin]

[ssl]

EOF
sudo chmod 0640 /etc/barbican/barbican.conf
sudo chown barbican:barbican /etc/barbican/barbican.conf

sudo usermod -a -G ssl-cert barbican

sudo su -s /bin/sh -c "barbican-manage db current" barbican

sudo systemctl restart \
  apache2 \
  barbican-worker \
  barbican-keystone-listener
