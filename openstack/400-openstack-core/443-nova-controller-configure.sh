#!/bin/bash

##############################################################################
# Configure Nova on Controller host
##############################################################################
sudo crudini --set /etc/nova/nova.conf api_database connection "mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova_api"
sudo crudini --set /etc/nova/nova.conf database connection "mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova"
sudo crudini --set /etc/nova/nova.conf DEFAULT transport_url "rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}:5672"
sudo crudini --set /etc/nova/nova.conf api auth_strategy "keystone"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken auth_type "password"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name "Default"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name "Default"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken project_name "service"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken username "nova"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken password "$NOVA_PASS"
sudo crudini --set /etc/nova/nova.conf DEFAULT my_ip "${CONTROLLER_IP_ADDRESS}"
sudo crudini --set /etc/nova/nova.conf DEFAULT use_neutron "true"
sudo crudini --set /etc/nova/nova.conf DEFAULT firewall_driver "nova.virt.firewall.NoopFirewallDriver"
sudo crudini --set /etc/nova/nova.conf vnc enabled "true"
sudo crudini --set /etc/nova/nova.conf vnc server_listen "\$my_ip"
sudo crudini --set /etc/nova/nova.conf vnc server_proxyclient_address "\$my_ip"
sudo crudini --set /etc/nova/nova.conf glance api_servers "http://${CONTROLLER_FQDN}:9292"
sudo crudini --set /etc/nova/nova.conf oslo_concurrency lock_path "/var/lib/nova/tmp"
sudo crudini --set /etc/nova/nova.conf placement region_name "RegionOne"
sudo crudini --set /etc/nova/nova.conf placement project_domain_name "Default"
sudo crudini --set /etc/nova/nova.conf placement project_name "service"
sudo crudini --set /etc/nova/nova.conf placement auth_type "password"
sudo crudini --set /etc/nova/nova.conf placement user_domain_name "Default"
sudo crudini --set /etc/nova/nova.conf placement auth_url "https://${CONTROLLER_FQDN}:5000/v3"
sudo crudini --set /etc/nova/nova.conf placement username "placement"
sudo crudini --set /etc/nova/nova.conf placement password "${PLACEMENT_PASS}"
sudo crudini --set /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval "300"

# Own additions
# sudo crudini --set /etc/nova/nova.conf cells enable "False"
# sudo crudini --set /etc/nova/nova.conf DEFAULT auth_strategy "keystone"
# sudo crudini --set /etc/nova/nova.conf DEFAULT bindir "/usr/bin"
sudo crudini --set /etc/nova/nova.conf DEFAULT debug "false"
sudo crudini --set /etc/nova/nova.conf DEFAULT default_floating_pool "ext-nat"
# sudo crudini --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver "nova.network.linux_net.LinuxOVSInterfaceDriver"
sudo crudini --set /etc/nova/nova.conf DEFAULT lock_path "/var/lock/nova"
sudo crudini --set /etc/nova/nova.conf DEFAULT log_dir "/var/log/nova"
# sudo crudini --set /etc/nova/nova.conf DEFAULT pybasedir "/usr/lib/python2.7/dist-packages"
sudo crudini --set /etc/nova/nova.conf DEFAULT state_path "/var/lib/nova"
sudo crudini --set /etc/nova/nova.conf DEFAULT syslog_log_facility "LOG_LOCAL0"
sudo crudini --set /etc/nova/nova.conf DEFAULT use_syslog "true"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken cafile "/etc/ssl/certs/ca-certificates.crt"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken certfile "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken keyfile "/etc/ssl/private/${CONTROLLER_FQDN}.key"
# sudo crudini --set /etc/nova/nova.conf keystone_authtoken region_name "RegionOne"
sudo crudini --set /etc/nova/nova.conf placement cafile "/etc/ssl/certs/ca-certificates.crt"
sudo crudini --set /etc/nova/nova.conf placement certfile "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"
sudo crudini --set /etc/nova/nova.conf placement keyfile "/etc/ssl/private/${CONTROLLER_FQDN}.key"
# sudo crudini --set /etc/nova/nova.conf placement os_region_name "openstack"

sudo chmod 0640 \
  /etc/nova/nova.conf
sudo chown nova:nova \
  /etc/nova/nova.conf

sudo usermod -a -G ssl-cert nova

sudo su -s /bin/sh -c "nova-manage api_db sync" nova
sudo su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
sudo su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
sudo su -s /bin/sh -c "nova-manage db sync" nova
sudo su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova

sudo systemctl restart \
  nova-api \
  nova-scheduler \
  nova-conductor \
  nova-novncproxy

# sudo systemctl restart \
#   nova-consoleauth
