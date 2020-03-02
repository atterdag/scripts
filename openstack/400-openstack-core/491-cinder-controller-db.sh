#!/bin/bash

##############################################################################
# Create Cinder DB on Controller host
##############################################################################
cat << EOF | sudo tee /var/lib/openstack/cinder.sql
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$CINDER_DBPASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$CINDER_DBPASS';
EOF
sudo chmod 0600 /var/lib/openstack/cinder.sql
sudo cat /var/lib/openstack/cinder.sql | sudo mysql --host=localhost --user=root --password="${ROOT_DBPASS}"
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=cinder --password=$CINDER_DBPASS cinder
