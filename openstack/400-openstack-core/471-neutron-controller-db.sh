#!/bin/bash

##############################################################################
# Create Neutron DB on Controller host
##############################################################################
cat << EOF | sudo tee ${OS_CONFIGURATION_DIRECTORY}/neutron.sql
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '${NEUTRON_DBPASS}';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '${NEUTRON_DBPASS}';
EOF
sudo chmod 0600 ${OS_CONFIGURATION_DIRECTORY}/neutron.sql
sudo cat ${OS_CONFIGURATION_DIRECTORY}/neutron.sql | sudo mysql --host=localhost --user=root --password="${ROOT_DBPASS}"
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=neutron --password=$NEUTRON_DBPASS neutron
