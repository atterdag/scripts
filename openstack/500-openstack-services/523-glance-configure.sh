#!/bin/sh

##############################################################################
# Configure Glance on Controller host
##############################################################################
sudo mv /etc/glance/glance-api.conf /etc/glance/glance-api.conf.org
cat << EOF | sudo tee /etc/glance/glance-api.conf
[DEFAULT]

[cors]

[cors.subdomain]

[database]
connection = mysql+pymysql://glance:${GLANCE_DBPASS}@${CONTROLLER_FQDN}/glance

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images

[image_format]
disk_formats = ami,ari,aki,vhd,vhdx,vmdk,raw,qcow2,vdi,iso,ploop.root-tar

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
username = glance
password = $GLANCE_PASS
auth_type = password

[matchmaker_redis]

[oslo_concurrency]
lock_path = /var/lock/glance

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_policy]

[paste_deploy]
flavor = keystone

[profiler]

[store_type_location_strategy]

[task]

[taskflow_executor]
EOF
sudo chmod 0640 /etc/glance/glance-api.conf
sudo chown glance:glance /etc/glance/glance-api.conf

sudo mv /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.org
cat << EOF | sudo tee /etc/glance/glance-registry.conf
[DEFAULT]

[database]
connection = mysql+pymysql://glance:${GLANCE_DBPASS}@${CONTROLLER_FQDN}/glance

[glance_store]
filesystem_store_datadir = /var/lib/glance/images

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
username = glance
password = $GLANCE_PASS
auth_type = password

[matchmaker_redis]

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_policy]

[paste_deploy]
flavor = keystone

[profiler]
EOF
sudo chmod 0640 /etc/glance/glance-registry.conf
sudo chown glance:glance /etc/glance/glance-registry.conf

sudo usermod -a -G ssl-cert glance

sudo su -s /bin/sh -c "glance-manage db_sync" glance

sudo systemctl restart \
  glance-registry \
  glance-api
