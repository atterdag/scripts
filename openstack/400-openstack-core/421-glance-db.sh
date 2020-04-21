#!/bin/bash

##############################################################################
# Create Glance DB on Controller host
##############################################################################
cat << EOF | sudo tee ${OPENSTACK_CONFIGURATION_DIRECTORY}/glance.sql
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '${GLANCE_DBPASS}';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '${GLANCE_DBPASS}';
EXIT
EOF
sudo chmod 0600 ${OPENSTACK_CONFIGURATION_DIRECTORY}/glance.sql
sudo cat ${OPENSTACK_CONFIGURATION_DIRECTORY}/glance.sql | sudo mysql --host=localhost --user=root --password="${ROOT_DBPASS}"
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=glance --password=$GLANCE_DBPASS glance
