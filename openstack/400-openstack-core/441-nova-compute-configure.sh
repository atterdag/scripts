#!/bin/bash

##############################################################################
# Configure Nova on Compute host
##############################################################################
# Overwrite existing /etc/nova/nova.conf if controller host is also compute host
sudo crudini --set /etc/nova/nova.conf DEFAULT default_floating_pool ext-nat
sudo crudini --set /etc/nova/nova.conf DEFAULT my_ip ${COMPUTE_IP_ADDRESS}
sudo crudini --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver nova.network.linux_net.LinuxOVSInterfaceDriver
sudo crudini --set /etc/nova/nova.conf DEFAULT use_neutron True
sudo crudini --set /etc/nova/nova.conf DEFAULT pybasedir /usr/lib/python2.7/dist-packages
sudo crudini --set /etc/nova/nova.conf DEFAULT bindir /usr/bin
sudo crudini --set /etc/nova/nova.conf DEFAULT state_path /var/lib/nova
sudo crudini --set /etc/nova/nova.conf DEFAULT log_dir /var/log/nova
sudo crudini --set /etc/nova/nova.conf DEFAULT lock_path /var/lock/nova
sudo crudini --set /etc/nova/nova.conf DEFAULT state_path /var/lib/nova
sudo crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
sudo crudini --set /etc/nova/nova.conf DEFAULT transport_url "rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}"
sudo crudini --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
sudo crudini --set /etc/nova/nova.conf DEFAULT remove_unused_base_images True
sudo crudini --set /etc/nova/nova.conf DEFAULT image_cache_manager_interval 10
sudo crudini --set /etc/nova/nova.conf DEFAULT remove_unused_original_minimum_age_seconds 10
sudo crudini --set /etc/nova/nova.conf DEFAULT remove_unused_resized_minimum_age_seconds 10
sudo crudini --set /etc/nova/nova.conf api_database connection "mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova_api"
sudo crudini --set /etc/nova/nova.conf cells enable False
sudo crudini --set /etc/nova/nova.conf cinder os_region_name RegionOne
sudo crudini --set /etc/nova/nova.conf database connection "mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova"
sudo crudini --set /etc/nova/nova.conf glance api_servers "http://${CONTROLLER_FQDN}:9292"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken certfile /etc/ssl/certs/${CONTROLLER_FQDN}.crt
sudo crudini --set /etc/nova/nova.conf keystone_authtoken keyfile /etc/ssl/private/${CONTROLLER_FQDN}.key
sudo crudini --set /etc/nova/nova.conf keystone_authtoken cafile /etc/ssl/certs/ca-certificates.crt
sudo crudini --set /etc/nova/nova.conf keystone_authtoken region_name RegionOne
sudo crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
sudo crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name Default
sudo crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name Default
sudo crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
sudo crudini --set /etc/nova/nova.conf keystone_authtoken username nova
sudo crudini --set /etc/nova/nova.conf keystone_authtoken password $NOVA_PASS
sudo crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
sudo crudini --set /etc/nova/nova.conf neutron url "http://${CONTROLLER_FQDN}:9696"
sudo crudini --set /etc/nova/nova.conf neutron region_name RegionOne
sudo crudini --set /etc/nova/nova.conf neutron service_metadata_proxy True
sudo crudini --set /etc/nova/nova.conf neutron METADATA_SECRET ${METADATA_SECRET}
sudo crudini --set /etc/nova/nova.conf neutron auth_type password
sudo crudini --set /etc/nova/nova.conf neutron auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/nova/nova.conf neutron project_name service
sudo crudini --set /etc/nova/nova.conf neutron project_domain_name Default
sudo crudini --set /etc/nova/nova.conf neutron username neutron
sudo crudini --set /etc/nova/nova.conf neutron user_domain_name Default
sudo crudini --set /etc/nova/nova.conf neutron password ${NEUTRON_PASS}
sudo crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
sudo crudini --set /etc/nova/nova.conf placement os_region_name openstack
sudo crudini --set /etc/nova/nova.conf placement auth_type password
sudo crudini --set /etc/nova/nova.conf placement auth_url "https://${CONTROLLER_FQDN}:5000/v3"
sudo crudini --set /etc/nova/nova.conf placement certfile /etc/ssl/certs/${CONTROLLER_FQDN}.crt
sudo crudini --set /etc/nova/nova.conf placement keyfile /etc/ssl/private/${CONTROLLER_FQDN}.key
sudo crudini --set /etc/nova/nova.conf placement cafile /etc/ssl/certs/ca-certificates.crt
sudo crudini --set /etc/nova/nova.conf placement region_name RegionOne
sudo crudini --set /etc/nova/nova.conf placement project_name service
sudo crudini --set /etc/nova/nova.conf placement project_domain_name Default
sudo crudini --set /etc/nova/nova.conf placement username placement
sudo crudini --set /etc/nova/nova.conf placement user_domain_name Default
sudo crudini --set /etc/nova/nova.conf placement password ${PLACEMENT_PASS}
sudo crudini --set /etc/nova/nova.conf placement_database connection "mysql+pymysql://placement:${PLACEMENT_DBPASS}@${CONTROLLER_FQDN}/placement"
sudo crudini --set /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval 300
sudo crudini --set /etc/nova/nova.conf vnc enabled True
sudo crudini --set /etc/nova/nova.conf vnc vncserver_listen \$my_ip
sudo crudini --set /etc/nova/nova.conf vnc vncserver_proxyclient_address \$my_ip
sudo crudini --set /etc/nova/nova.conf vnc novncproxy_base_url "http://${CONTROLLER_FQDN}:6080/vnc_auto.html"
sudo crudini --set /etc/nova/nova.conf vnc xvpvncproxy_base_url "http://${CONTROLLER_FQDN}:6081/console"

sudo chmod 0640 \
  /etc/nova/nova.conf
sudo chown nova:nova \
  /etc/nova/nova.conf

sudo modprobe nbd
cat << EOF | sudo tee /etc/modules-load.d/nbd.conf
nbd
EOF

sudo usermod -a -G ssl-cert nova

# On compute node restart compute
sudo systemctl restart \
  nova-compute
