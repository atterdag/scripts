#!/bin/bash

##############################################################################
# Configure Keystone on Controller host
##############################################################################
sudo crudini --set /etc/keystone/keystone.conf database connection "mysql+pymysql://keystone:${KEYSTONE_DBPASS}@${CONTROLLER_FQDN}/keystone"
sudo crudini --set /etc/keystone/keystone.conf token provider "fernet"

# Own additions
sudo crudini --set /etc/keystone/keystone.conf catalog template_file "/etc/keystone/default_catalog.templates"
sudo crudini --set /etc/keystone/keystone.conf DEFAULT debug "false"
sudo crudini --set /etc/keystone/keystone.conf DEFAULT log_dir "/var/log/keystone"
sudo crudini --set /etc/keystone/keystone.conf DEFAULT log_file "keystone.log"
sudo crudini --set /etc/keystone/keystone.conf DEFAULT syslog_log_facility "LOG_LOCAL0"
sudo crudini --set /etc/keystone/keystone.conf DEFAULT use_syslog "true"
sudo crudini --set /etc/keystone/keystone.conf DEFAULT transport_url "rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}:5671/?ssl=1" 
sudo crudini --set /etc/keystone/keystone.conf extra_headers Distribution "Ubuntu"
sudo crudini --set /etc/keystone/keystone.conf identity driver "sql"

sudo chmod 0640 \
  /etc/keystone/keystone.conf
sudo chown keystone:keystone \
  /etc/keystone/keystone.conf

sudo su -s /bin/sh -c "keystone-manage db_sync" keystone

sudo keystone-manage fernet_setup \
  --keystone-user keystone \
  --keystone-group keystone
sudo keystone-manage credential_setup \
  --keystone-user keystone \
  --keystone-group keystone
sudo keystone-manage bootstrap \
  --bootstrap-password $ADMIN_PASS \
  --bootstrap-admin-url https://${CONTROLLER_FQDN}:5000/v3/ \
  --bootstrap-internal-url https://${CONTROLLER_FQDN}:5000/v3/ \
  --bootstrap-public-url https://${CONTROLLER_FQDN}:5000/v3/ \
  --bootstrap-region-id RegionOne
