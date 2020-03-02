#!/bin/bash

##############################################################################
# Configure Nova on Controller host
##############################################################################
sudo crudini --set /etc/placement/placement.conf placement_database connection "mysql+pymysql://placement:${PLACEMENT_DBPASS}@${CONTROLLER_FQDN}/placement"
sudo crudini --set /etc/placement/placement.conf api auth_strategy keystone
sudo crudini --set /etc/placement/placement.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
# sudo crudini --set /etc/placement/placement.conf keystone_authtoken www_authenticate_uri "http://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/placement/placement.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000/v3"
# sudo crudini --set /etc/placement/placement.conf keystone_authtoken auth_url "http://${CONTROLLER_FQDN}:5000/v3"
sudo crudini --set /etc/placement/placement.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
sudo crudini --set /etc/placement/placement.conf keystone_authtoken auth_type "password"
sudo crudini --set /etc/placement/placement.conf keystone_authtoken project_domain_name "Default"
sudo crudini --set /etc/placement/placement.conf keystone_authtoken user_domain_name "Default"
sudo crudini --set /etc/placement/placement.conf keystone_authtoken project_name "service"
sudo crudini --set /etc/placement/placement.conf keystone_authtoken username "placement"
sudo crudini --set /etc/placement/placement.conf keystone_authtoken password "${PLACEMENT_PASS}"

# Own additions
sudo crudini --set /etc/placement/placement.conf DEFAULT auth_strategy "keystone"
sudo crudini --set /etc/placement/placement.conf DEFAULT debug "false"
sudo crudini --set /etc/placement/placement.conf DEFAULT log_dir "/var/log/placement"
sudo crudini --set /etc/placement/placement.conf DEFAULT state_path "/var/lib/placement"
sudo crudini --set /etc/placement/placement.conf DEFAULT syslog_log_facility "LOG_LOCAL0"
sudo crudini --set /etc/placement/placement.conf DEFAULT use_syslog "true"
sudo crudini --set /etc/placement/placement.conf keystone_authtoken cafile "/etc/ssl/certs/ca-certificates.crt"
sudo crudini --set /etc/placement/placement.conf keystone_authtoken certfile "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"
sudo crudini --set /etc/placement/placement.conf keystone_authtoken keyfile "/etc/ssl/private/${CONTROLLER_FQDN}.key"

sudo chmod 0640 \
  /etc/placement/placement.conf
sudo chown placement:placement \
  /etc/placement/placement.conf

sudo usermod -a -G ssl-cert placement

sudo su -s /bin/sh -c "placement-manage db sync" placement

cat <<EOF | sudo tee /etc/apache2/conf-available/00-placement-api.conf
<Directory /usr/bin>
   <IfVersion >= 2.4>
      Require all granted
   </IfVersion>
   <IfVersion < 2.4>
      Order allow,deny
      Allow from all
   </IfVersion>
</Directory>
EOF

sudo a2enconf 00-placement-api

sudo systemctl restart \
  apache2
