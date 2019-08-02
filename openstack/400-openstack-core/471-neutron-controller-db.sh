#!/bin/bash

##############################################################################
# Create Neutron DB on Controller host
##############################################################################
cat << EOF | sudo tee /var/lib/openstack/neutron.sql
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '${NEUTRON_DBPASS}';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '${NEUTRON_DBPASS}';
EOF
sudo chmod 0600 /var/lib/openstack/neutron.sql
sudo cat /var/lib/openstack/neutron.sql | sudo mysql --host=localhost --user=root
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=neutron --password=$NEUTRON_DBPASS neutron
