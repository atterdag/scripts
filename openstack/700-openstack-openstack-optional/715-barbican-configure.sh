#!/bin/bash

##############################################################################
# Install Barbican on Controller host
##############################################################################
sudo crudini --set /etc/barbican/barbican.conf DEFAULT sql_connection "mysql+pymysql://barbican:${BARBICAN_DBPASS}@${CONTROLLER_FQDN}/barbican"
sudo crudini --set /etc/barbican/barbican.conf DEFAULT transport_url "rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}:5671/?ssl=1"
sudo crudini --set /etc/barbican/barbican.conf certificate namespace "barbican.certificate.plugin"
sudo crudini --set /etc/barbican/barbican.conf certificate enabled_certificate_plugins "dogtag"
sudo crudini --set /etc/barbican/barbican.conf dogtag_plugin pem_path "/etc/barbican/kra-agent.pem"
sudo crudini --set /etc/barbican/barbican.conf dogtag_plugin dogtag_host "${IDM_ONE_FQDN}"
sudo crudini --set /etc/barbican/barbican.conf dogtag_plugin dogtag_port "8443"
sudo crudini --set /etc/barbican/barbican.conf dogtag_plugin nss_db_path "/etc/barbican/alias"
sudo crudini --set /etc/barbican/barbican.conf dogtag_plugin nss_db_path_ca "/etc/barbican/alias-ca"
sudo crudini --set /etc/barbican/barbican.conf dogtag_plugin nss_password "${PKI_SERVER_DATABASE_PASSWORD}"
sudo crudini --set /etc/barbican/barbican.conf dogtag_plugin simple_cmc_profile "caOtherCert"
sudo crudini --set /etc/barbican/barbican.conf dogtag_plugin ca_expiration_time "1"
sudo crudini --set /etc/barbican/barbican.conf dogtag_plugin plugin_working_dir "/etc/barbican/dogtag"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken certfile "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken keyfile "/etc/ssl/private/${CONTROLLER_FQDN}.key"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken cafile "/etc/ssl/certs/ca-certificates.crt"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken region_name "RegionOne"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken project_domain_name "Default"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken user_domain_name "Default"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken project_name "service"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken username "barbican"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken password "$BARBICAN_PASS"
sudo crudini --set /etc/barbican/barbican.conf keystone_authtoken auth_type "password"
sudo crudini --set /etc/barbican/barbican.conf secretstore namespace "barbican.secretstore.plugin"
sudo crudini --set /etc/barbican/barbican.conf secretstore enabled_secretstore_plugins "dogtag_crypto"

sudo chmod 0640 \
  /etc/barbican/barbican.conf
sudo chown barbican:barbican \
  /etc/barbican/barbican.conf

sudo usermod -a -G ssl-cert barbican

sudo su -s /bin/sh -c "barbican-manage db current" barbican

sudo systemctl restart \
  apache2 \
  barbican-worker \
  barbican-keystone-listener
