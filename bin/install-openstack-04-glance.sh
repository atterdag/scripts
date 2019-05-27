#!/bin/sh

##############################################################################
# Install Glance on Controller host
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet glance

cat << EOF | sudo tee /var/lib/openstack/glance.sql
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '${GLANCE_DBPASS}';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '${GLANCE_DBPASS}';
EXIT
EOF
sudo chmod 0600 /var/lib/openstack/glance.sql
sudo cat /var/lib/openstack/glance.sql | sudo mysql --host=localhost --user=root
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=glance --password=$GLANCE_DBPASS glance

openstack user create \
  --domain default \
  --password $GLANCE_PASS \
  glance
openstack role add \
  --project service \
  --user glance \
  admin
openstack service create \
  --name glance \
  --description 'OpenStack Image' \
  image
openstack endpoint create \
  --region RegionOne \
  image public http://${CONTROLLER_FQDN}:9292
openstack endpoint create \
  --region RegionOne \
  image internal http://${CONTROLLER_FQDN}:9292
openstack endpoint create \
  --region RegionOne \
  image admin http://${CONTROLLER_FQDN}:9292

sudo usermod -a -G ssl-cert glance

sudo mv /etc/glance/glance-api.conf /etc/glance/glance-api.conf.org
cat << EOF | sudo tee /etc/glance/glance-api.conf
[DEFAULT]
#ca_file = /etc/ssl/certs/${SSL_CA_NAME}.pem
#cert_file = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
#key_file = /etc/ssl/private/${CONTROLLER_FQDN}.key

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
cafile = /etc/ssl/certs/${SSL_CA_NAME}.pem
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
#ca_file = /etc/ssl/certs/${SSL_CA_NAME}.pem
#cert_file = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
#key_file = /etc/ssl/private/${CONTROLLER_FQDN}.key

[database]
connection = mysql+pymysql://glance:${GLANCE_DBPASS}@${CONTROLLER_FQDN}/glance

[glance_store]
filesystem_store_datadir = /var/lib/glance/images

[keystone_authtoken]
www_authenticate_uri = https://${CONTROLLER_FQDN}:5000
auth_url = https://${CONTROLLER_FQDN}:5000
certfile = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
keyfile = /etc/ssl/private/${CONTROLLER_FQDN}.key
cafile = /etc/ssl/certs/${SSL_CA_NAME}.pem
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

sudo su -s /bin/sh -c "glance-manage db_sync" glance

sudo systemctl restart \
  glance-registry \
  glance-api

sudo wget \
  --continue \
  --output-document=/var/lib/openstack/cirros-0.4.0-x86_64-disk.img \
  http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img

sudo -E openstack image create "cirros-0.4.0" \
  --file /var/lib/openstack/cirros-0.4.0-x86_64-disk.img \
  --disk-format qcow2 \
  --container-format bare \
  --public

openstack image list
