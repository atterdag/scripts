#!/bin/bash

##############################################################################
# Configure Designate on Controller host
##############################################################################
sudo crudini --set /etc/designate/designate.conf DEFAULT verbose "True"
sudo crudini --set /etc/designate/designate.conf DEFAULT debug "False"
sudo crudini --set /etc/designate/designate.conf DEFAULT transport_url "rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken certfile "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken keyfile "/etc/ssl/private/${CONTROLLER_FQDN}.key"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken cafile "/etc/ssl/certs/ca-certificates.crt"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken region_name "RegionOne"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken project_domain_name "Default"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken user_domain_name "Default"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken project_name "service"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken username "designate"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken password "$DESIGNATE_PASS"
sudo crudini --set /etc/designate/designate.conf keystone_authtoken auth_type "password"
sudo crudini --set /etc/designate/designate.conf service:api listen "0.0.0.0:9001"
sudo crudini --set /etc/designate/designate.conf service:api auth_strategy "keystone"
sudo crudini --set /etc/designate/designate.conf service:api api_base_uri "http://${CONTROLLER_FQDN}:9001/"
sudo crudini --set /etc/designate/designate.conf service:api enable_api_v2 "True"
sudo crudini --set /etc/designate/designate.conf service:api enabled_extensions_v2 "quotas,reports"
sudo crudini --set /etc/designate/designate.conf service:worker enabled "True"
sudo crudini --set /etc/designate/designate.conf service:worker notify "True"
sudo crudini --set /etc/designate/designate.conf storage:sqlalchemy connection "mysql+pymysql://designate:${DESIGNATE_DBPASS}@${CONTROLLER_FQDN}/designate"

sudo chmod 0660 \
  /etc/designate/designate.conf
sudo chown designate:designate \
  /etc/designate/designate.conf

sudo usermod -a -G ssl-cert designate

sudo su -s /bin/sh -c "designate-manage database sync" designate

sudo systemctl restart \
  designate-central \
  designate-api
