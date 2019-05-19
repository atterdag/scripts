#!/bin/sh

##############################################################################
# Install Designate on Controller host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  designate

cat > /var/lib/openstack/designate.sql << EOF
CREATE DATABASE designate CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON designate.* TO 'designate'@'localhost' IDENTIFIED BY '${DESIGNATE_DBPASS}';
GRANT ALL PRIVILEGES ON designate.* TO 'designate'@'%' IDENTIFIED BY '${DESIGNATE_DBPASS}';
CREATE DATABASE designate_pool_manager CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON designate_pool_manager.* TO 'designate'@'localhost' IDENTIFIED BY '${DESIGNATE_DBPASS}';
GRANT ALL PRIVILEGES ON designate_pool_manager.* TO 'designate'@'%' IDENTIFIED BY '${DESIGNATE_DBPASS}';
EOF
mysql --user=root --password="${ROOT_DBPASS}" < /var/lib/openstack/designate.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=designate --password=$DESIGNATE_DBPASS designate
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=designate --password=$DESIGNATE_DBPASS designate_pool_manager

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
openstack endpoint create \
  --region RegionOne \
  dns internal  http://${CONTROLLER_FQDN}:9001/
openstack endpoint create \
  --region RegionOne \
  dns admin  http://${CONTROLLER_FQDN}:9001/

usermod -a -G ssl-cert designate

mv /etc/designate/designate.conf /etc/designate/designate.conf.org
cat > /etc/designate/designate.conf << EOF
[DEFAULT]
verbose = True
debug = False
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}

[oslo_messaging_rabbit]

[service:central]

[service:api]
listen = 0.0.0.0:9001
auth_strategy = keystone
api_base_uri = http://${CONTROLLER_FQDN}:9001/
enable_api_v1 = True
enabled_extensions_v1 = diagnostics, quotas, reports, sync, touch
enable_api_v2 = True
enabled_extensions_v2 = quotas, reports

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
username = designate
password = $DESIGNATE_PASS
auth_type = password

[cors]

[cors.subdomain]

[service:sink]

[service:mdns]

[service:agent]

[service:producer]

[producer_task:domain_purge]

[producer_task:delayed_notify]

[producer_task:worker_periodic_recovery]

[service:pool_manager]
pool_id = 794ccc2c-d751-44fe-b57f-8894c9f5c842

[service:worker]
enabled = True
notify = True

[pool_manager_cache:sqlalchemy]
connection = mysql+pymysql://designate:${DESIGNATE_DBPASS}@${CONTROLLER_FQDN}/designate_pool_manager

[pool_manager_cache:memcache]

[network_api:neutron]
timeout = 30
endpoints = RegionOne|http://${CONTROLLER_FQDN}:9696
endpoint_type = publicURL
auth_type = password
auth_url = https://${CONTROLLER_FQDN}:5000
auth_strategy = keystone
project_name = service
project_domain_name = Default
username = neutron
user_domain_name = Default
password = ${DESIGNATE_PASS}
#insecure = False
#ca_certificates_file =

[storage:sqlalchemy]
connection = mysql+pymysql://designate:${DESIGNATE_DBPASS}@${CONTROLLER_FQDN}/designate

[handler:nova_fixed]

[handler:neutron_floatingip]

[backend:agent:bind9]

[backend:agent:knot2]

[backend:agent:djbdns]

[backend:agent:denominator]

[backend:agent:gdnsd]

[backend:agent:msdns]

[oslo_concurrency]

[coordination]

EOF
chmod 0660 /etc/designate/designate.conf
chown designate:designate /etc/designate/designate.conf

su -s /bin/sh -c "designate-manage database sync" designate
su -s /bin/sh -c "designate-manage pool-manager-cache sync" designate

cat > /etc/designate/pools.yaml << EOF
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

systemctl restart \
  designate-central \
  designate-api \
  designate-agent \
  designate-mdns \
  designate-pool-manager \
  designate-sink \
  designate-zone-manager

su -s /bin/sh -c "designate-manage pool update" designate
