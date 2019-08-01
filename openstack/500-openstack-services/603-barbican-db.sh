#!/bin/sh

##############################################################################
# Install Barbican on Controller host
##############################################################################
cat << EOF | sudo tee /var/lib/openstack/barbican.sql
CREATE DATABASE barbican;
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'localhost' IDENTIFIED BY '${BARBICAN_DBPASS}';
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'%' IDENTIFIED BY '${BARBICAN_DBPASS}';
EOF
sudo chmod 0600 /var/lib/openstack/barbican.sql
sudo cat /var/lib/openstack/barbican.sql | sudo mysql --host=localhost --user=root
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=barbican --password=$BARBICAN_DBPASS barbican
