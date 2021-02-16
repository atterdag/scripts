#!/bin/bash

##############################################################################
# Install Barbican on Controller host
##############################################################################
cat << EOF | sudo tee ${OS_CONFIGURATION_DIRECTORY}/barbican.sql
CREATE DATABASE barbican;
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'localhost' IDENTIFIED BY '${BARBICAN_DBPASS}';
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'%' IDENTIFIED BY '${BARBICAN_DBPASS}';
EOF
sudo chmod 0600 ${OS_CONFIGURATION_DIRECTORY}/barbican.sql
sudo cat ${OS_CONFIGURATION_DIRECTORY}/barbican.sql | sudo mysql --host=localhost --user=root --password="${ROOT_DBPASS}"
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=barbican --password=$BARBICAN_DBPASS barbican
