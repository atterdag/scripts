#!/bin/sh

##############################################################################
# Create Glance DB on Controller host
##############################################################################
cat << EOF | sudo tee /var/lib/openstack/glance.sql
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '${GLANCE_DBPASS}';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '${GLANCE_DBPASS}';
EXIT
EOF
sudo chmod 0600 /var/lib/openstack/glance.sql
sudo cat /var/lib/openstack/glance.sql | sudo mysql --host=localhost --user=root
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=glance --password=$GLANCE_DBPASS glance
