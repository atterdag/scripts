#!/bin/bash

##############################################################################
# Create Nova DB on Controller host
##############################################################################
cat << EOF | sudo tee ${OS_CONFIGURATION_DIRECTORY}/placement.sql
CREATE DATABASE placement;
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY '${PLACEMENT_DBPASS}';
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY '${PLACEMENT_DBPASS}';
EOF
sudo chmod 0600 ${OS_CONFIGURATION_DIRECTORY}/placement.sql
sudo cat ${OS_CONFIGURATION_DIRECTORY}/placement.sql | sudo mysql --host=localhost --user=root --password="${ROOT_DBPASS}"
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=placement --password=$PLACEMENT_DBPASS placement
