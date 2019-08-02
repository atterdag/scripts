#!/bin/bash

##############################################################################
# Configure Designate on Controller host
##############################################################################
sudo mv /etc/designate/designate.conf /etc/designate/designate.conf.org
cat << EOF | sudo tee /etc/designate/designate.conf
[DEFAULT]
verbose = True
debug = False
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}

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
username = designate
password = $DESIGNATE_PASS
auth_type = password

[matchmaker_redis]

[monasca:statsd]

[network_api:neutron]

[oslo_concurrency]

[oslo_messaging_amqp]

[oslo_messaging_kafka]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[pool_manager_cache:memcache]

[pool_manager_cache:sqlalchemy]

[producer_task:delayed_notify]

[producer_task:periodic_exists]

[producer_task:periodic_secondary_refresh]

[producer_task:worker_periodic_recovery]

[producer_task:zone_purge]

[proxy]

[service:agent]

[service:api]
listen = 0.0.0.0:9001
auth_strategy = keystone
api_base_uri = http://${CONTROLLER_FQDN}:9001/
enable_api_v2 = True
enabled_extensions_v2 = quotas, reports

[service:central]
[service:mdns]

[service:pool_manager]

[service:producer]

[service:sink]

[service:worker]
enabled = True
notify = True

[service:zone_manager]

[ssl]

[storage:sqlalchemy]
connection = mysql+pymysql://designate:${DESIGNATE_DBPASS}@${CONTROLLER_FQDN}/designate
EOF
sudo chmod 0660 /etc/designate/designate.conf
sudo chown designate:designate /etc/designate/designate.conf

sudo usermod -a -G ssl-cert designate

sudo su -s /bin/sh -c "designate-manage database sync" designate

sudo systemctl restart \
  designate-central \
  designate-api
