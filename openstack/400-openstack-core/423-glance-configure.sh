#!/bin/bash

##############################################################################
# Configure Glance on Controller host
##############################################################################
sudo crudini --set /etc/glance/glance-api.conf database connection "mysql+pymysql://glance:${GLANCE_DBPASS}@${CONTROLLER_FQDN}/glance"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_type "password"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken project_domain_name "Default"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken user_domain_name "Default"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken project_name "service"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken username "glance"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken password "$GLANCE_PASS"
sudo crudini --set /etc/glance/glance-api.conf glance_store stores "file,http"
sudo crudini --set /etc/glance/glance-api.conf glance_store default_store "file"
sudo crudini --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir "/var/lib/glance/images"
sudo crudini --set /etc/glance/glance-registry.conf database connection "mysql+pymysql://glance:${GLANCE_DBPASS}@${CONTROLLER_FQDN}/glance"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_type "password"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_domain_name "Default"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken user_domain_name "Default"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_name "service"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken username "glance"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken password "$GLANCE_PASS"
sudo crudini --set /etc/glance/glance-api.conf paste_deploy flavor "keystone"

# Own additions
sudo crudini --set /etc/glance/glance-api.conf DEFAULT debug "false"
sudo crudini --set /etc/glance/glance-api.conf DEFAULT syslog_log_facility "LOG_LOCAL0"
sudo crudini --set /etc/glance/glance-api.conf DEFAULT use_syslog "true"
sudo crudini --set /etc/glance/glance-api.conf image_format disk_formats "ami,ari,aki,vhd,vhdx,vmdk,raw,qcow2,vdi,iso,ploop.root-tar"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken cafile "/etc/ssl/certs/ca-certificates.crt"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken certfile "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken keyfile "/etc/ssl/private/${CONTROLLER_FQDN}.key"
sudo crudini --set /etc/glance/glance-api.conf keystone_authtoken region_name "RegionOne"
sudo crudini --set /etc/glance/glance-api.conf oslo_concurrency lock_path "/var/lock/glance"
sudo crudini --set /etc/glance/glance-registry.conf DEFAULT debug "false"
sudo crudini --set /etc/glance/glance-registry.conf DEFAULT syslog_log_facility "LOG_LOCAL0"
sudo crudini --set /etc/glance/glance-registry.conf DEFAULT use_syslog "true"
sudo crudini --set /etc/glance/glance-registry.conf glance_store filesystem_store_datadir "/var/lib/glance/images"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken cafile "/etc/ssl/certs/ca-certificates.crt"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken certfile "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken keyfile "/etc/ssl/private/${CONTROLLER_FQDN}.key"
sudo crudini --set /etc/glance/glance-registry.conf keystone_authtoken region_name "RegionOne"

sudo chmod 0640 \
  /etc/glance/glance-api.conf \
  /etc/glance/glance-registry.conf
sudo chown glance:glance \
  /etc/glance/glance-api.conf \
  /etc/glance/glance-registry.conf

sudo usermod -a -G ssl-cert glance

sudo su -s /bin/sh -c "glance-manage db_sync" glance

sudo systemctl restart \
  glance-registry \
  glance-api
