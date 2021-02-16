#!/bin/bash

##############################################################################
# Create Keystone DB on Controller host
##############################################################################
cat << EOF | sudo tee ${OS_CONFIGURATION_DIRECTORY}/keystone.sql
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_DBPASS}';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_DBPASS}';
EXIT
EOF
sudo chmod 0600 ${OS_CONFIGURATION_DIRECTORY}/keystone.sql
sudo cat ${OS_CONFIGURATION_DIRECTORY}/keystone.sql \
  | sudo mysql --host=localhost --user=root --password="${ROOT_DBPASS}"
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=keystone --password=$KEYSTONE_DBPASS keystone
