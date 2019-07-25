#!/bin/sh

##############################################################################
# Install Designate on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  designate

cat << EOF | sudo tee /var/lib/openstack/designate.sql
CREATE DATABASE designate CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON designate.* TO 'designate'@'localhost' IDENTIFIED BY '${DESIGNATE_DBPASS}';
GRANT ALL PRIVILEGES ON designate.* TO 'designate'@'%' IDENTIFIED BY '${DESIGNATE_DBPASS}';
EOF
sudo chmod 0600 /var/lib/openstack/designate.sql
sudo cat /var/lib/openstack/designate.sql | sudo mysql --host=localhost --user=root
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=designate --password=$DESIGNATE_DBPASS designate

openstack user create \
  --domain default \
  --password $DESIGNATE_PASS \
  designate
openstack role add \
  --project service \
  --user designate \
  admin
openstack service create \
  --name designate \
  --description 'OpenStack DNS' \
  dns
openstack endpoint create \
  --region RegionOne \
  dns public http://${CONTROLLER_FQDN}:9001/

sudo usermod -a -G ssl-cert designate

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

sudo su -s /bin/sh -c "designate-manage database sync" designate

sudo systemctl restart \
  designate-central \
  designate-api

cat << EOF | sudo tee /etc/designate/pools.yaml
- name: default
  # The name is immutable. There will be no option to change the name after
  # creation and the only way will to change it will be to delete it
  # (and all zones associated with it) and recreate it.
  description: Default Pool

  attributes: {}

  # List out the NS records for zones hosted within this pool
  # This should be a record that is created outside of designate, that
  # points to the public IP of the controller node.
  ns_records:
    - hostname: ${CONTROLLER_FQDN}.
      priority: 1

  # List out the nameservers for this pool. These are the actual BIND servers.
  # We use these to verify changes have propagated to all nameservers.
  nameservers:
    - host: $(host ${CONTROLLER_FQDN} | sed "s|${CONTROLLER_FQDN} has address ||")
      port: 53

  # List out the targets for this pool. For BIND there will be one
  # entry for each BIND server, as we have to run rndc command on each server
  targets:
    - type: bind9
      description: BIND9 Server 1

      # List out the designate-mdns servers from which BIND servers should
      # request zone transfers (AXFRs) from.
      # This should be the IP of the controller node.
      # If you have multiple controllers you can add multiple masters
      # by running designate-mdns on them, and adding them here.
      masters:
        - host: $(host ${CONTROLLER_FQDN} | sed "s|${CONTROLLER_FQDN} has address ||")
          port: 5354

      # BIND Configuration options
      options:
        host: $(host ${CONTROLLER_FQDN} | sed "s|${CONTROLLER_FQDN} has address ||")
        port: 53
        rndc_host: $(host ${CONTROLLER_FQDN} | sed "s|${CONTROLLER_FQDN} has address ||")
        rndc_port: 953
        rndc_key_file: /etc/bind/designate.key
EOF
sudo chmod 0660 /etc/designate/designate.conf
sudo chown designate:designate /etc/designate/designate.conf

sudo su -s /bin/sh -c "designate-manage pool update" designate

sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  designate-worker \
  designate-producer \
  designate-mdns

sudo systemctl restart \
  designate-worker \
  designate-producer \
  designate-mdns

openstack dns service list

##############################################################################
# Create DNS zones, and records for controller
##############################################################################
echo openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  ${DNS_DOMAIN}.
echo openstack zone create \
  --email hostmaster@${DNS_DOMAIN} \
  ${DNS_REVERSE_DOMAIN}.
echo openstack recordset create \
  --record "${CONTROLLER_IP_ADDRESS}" \
  --type A ${DNS_DOMAIN}. \
  $(echo $CONTROLLER_FQDN | awk -F'.' '{print $1}')
echo openstack recordset create \
  --record "${CONTROLLER_FQDN}." \
  --type PTR ${DNS_REVERSE_DOMAIN}. \
  $(echo $CONTROLLER_IP_ADDRESS | awk -F'.' '{print $4}')

##############################################################################
# Include designate commands in bash completion on Controller host
##############################################################################
openstack complete | sudo tee /etc/bash_completion.d/osc.bash_completion > /dev/null
source /etc/bash_completion
