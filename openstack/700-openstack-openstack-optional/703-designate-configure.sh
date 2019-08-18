#!/bin/bash

##############################################################################
# Configure Designate on Controller host
##############################################################################
if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  ssh_cmd="ssh -o StrictHostKeyChecking=no ubuntu@${NS_IP_ADDRESS}"
else
  ssh_cmd=""
fi
$ssh_cmd sudo crudini --set /etc/designate/designate.conf DEFAULT verbose "True"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf DEFAULT debug "False"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf DEFAULT transport_url "rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken certfile "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken keyfile "/etc/ssl/private/${CONTROLLER_FQDN}.key"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken cafile "/etc/ssl/certs/ca-certificates.crt"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken region_name "RegionOne"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken project_domain_name "Default"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken user_domain_name "Default"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken project_name "service"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken username "designate"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken password "$DESIGNATE_PASS"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf keystone_authtoken auth_type "password"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf service:api listen "0.0.0.0:9001"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf service:api auth_strategy "keystone"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf service:api api_base_uri "http://${NS_FQDN}:9001/"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf service:api enable_api_v2 "True"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf service:api enabled_extensions_v2 "quotas,reports"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf service:worker enabled "True"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf service:worker notify "True"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf storage:sqlalchemy connection "mysql+pymysql://designate:${DESIGNATE_DBPASS}@${CONTROLLER_FQDN}/designate"
$ssh_cmd sudo crudini --set /etc/designate/designate.conf database connection "mysql+pymysql://designate:${DESIGNATE_DBPASS}@${CONTROLLER_FQDN}/designate"

$ssh_cmd sudo chmod 0660 \
  /etc/designate/designate.conf
$ssh_cmd sudo chown designate:designate \
  /etc/designate/designate.conf

$ssh_cmd sudo usermod -a -G ssl-cert designate

$ssh_cmd sudo su -s /bin/bash -c "designate-manage database sync" designate

$ssh_cmd sudo systemctl restart \
  designate-central \
  designate-api
