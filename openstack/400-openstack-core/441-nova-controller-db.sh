#!/bin/bash

##############################################################################
# Create Nova DB on Controller host
##############################################################################
cat << EOF | sudo tee /var/lib/openstack/nova.sql
CREATE DATABASE nova_api;
CREATE DATABASE nova;
CREATE DATABASE nova_cell0;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';
EOF
sudo chmod 0600 /var/lib/openstack/nova.sql
sudo cat /var/lib/openstack/nova.sql | sudo mysql --host=localhost --user=root --password="${ROOT_DBPASS}"
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=nova --password=$NOVA_DBPASS nova_api
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=nova --password=$NOVA_DBPASS nova
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=nova --password=$NOVA_DBPASS nova_cell0
