#!/bin/bash

##############################################################################
# Configure Neutron on Controller host
##############################################################################
sudo crudini --set /etc/neutron/neutron.conf database connection "mysql+pymysql://neutron:${NEUTRON_DBPASS}@${CONTROLLER_FQDN}/neutron"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin "ml2"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins "router"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips "true"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT transport_url "rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}:5671/?ssl=1"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy "keystone"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type "password"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name "Default"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name "Default"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name "service"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken username "neutron"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken password "$NEUTRON_PASS"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes "true"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes "true"
sudo crudini --set /etc/neutron/neutron.conf nova auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/neutron/neutron.conf nova auth_type "password"
sudo crudini --set /etc/neutron/neutron.conf nova project_domain_name "Default"
sudo crudini --set /etc/neutron/neutron.conf nova user_domain_name "Default"
sudo crudini --set /etc/neutron/neutron.conf nova region_name "RegionOne"
sudo crudini --set /etc/neutron/neutron.conf nova project_name "service"
sudo crudini --set /etc/neutron/neutron.conf nova username "nova"
sudo crudini --set /etc/neutron/neutron.conf nova password "$NOVA_PASS"
sudo crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path "/var/lib/neutron/tmp"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers "flat,vlan,vxlan"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types "vxlan"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers "linuxbridge,l2population"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers "port_security"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks "${OS_CONTROLLER_PROVIDER_VIRTUAL_NIC}"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges "1:1000"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset "true"
sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings "${OS_CONTROLLER_PROVIDER_VIRTUAL_NIC}:${OS_CONTROLLER_PROVIDER_PHYSICAL_NIC}"
sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan "true"
sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip "${OS_CONTROLLER_IP_ADDRESS}"
sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population "true"
sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group "true"
sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver "neutron.agent.linux.iptables_firewall.IptablesFirewallDriver"
sudo crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver "linuxbridge"
sudo crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver "linuxbridge"
sudo crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver "neutron.agent.linux.dhcp.Dnsmasq"
sudo crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata "true"
sudo crudini --set /etc/neutron/metadata_agent.ini DEFAULT METADATA_SECRET "$METADATA_SECRET"
sudo crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_host "$CONTROLLER_FQDN"
sudo crudini --set /etc/nova/nova.conf neutron auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/nova/nova.conf neutron auth_type "password"
sudo crudini --set /etc/nova/nova.conf neutron project_domain_name "default"
sudo crudini --set /etc/nova/nova.conf neutron user_domain_name "default"
sudo crudini --set /etc/nova/nova.conf neutron region_name "RegionOne"
sudo crudini --set /etc/nova/nova.conf neutron project_name "service"
sudo crudini --set /etc/nova/nova.conf neutron username "neutron"
sudo crudini --set /etc/nova/nova.conf neutron password "$NEUTRON_PASS"
sudo crudini --set /etc/nova/nova.conf neutron service_metadata_proxy "true"
sudo crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret "$METADATA_SECRET"

# Own additions
sudo crudini --set /etc/neutron/neutron.conf agent root_helper "sudo neutron-rootwrap /etc/neutron/rootwrap.conf"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT debug "false"
#sudo crudini --set /etc/neutron/neutron.conf DEFAULT dhcp_agents_per_network "2"
# sudo crudini --set /etc/neutron/neutron.conf DEFAULT nova_metadata_ip "${CONTROLLER_FQDN}"
#sudo crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend "rabbit"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT syslog_log_facility "LOG_LOCAL0"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT use_syslog "true"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken cafile "/etc/ssl/certs/ca-certificates.crt"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken certfile "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken keyfile "/etc/ssl/private/${CONTROLLER_FQDN}.key"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken region_name "RegionOne"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 external_network_type "vlan"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types "vlan,vxlan"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges "${OS_CONTROLLER_PROVIDER_VIRTUAL_NIC}:1:4094"

sudo chmod 0660 \
  /etc/neutron/neutron.conf \
  /etc/neutron/metadata_agent.ini
sudo chown neutron:neutron \
  /etc/neutron/neutron.conf \
  /etc/neutron/metadata_agent.ini

sudo usermod -a -G ssl-cert neutron

sudo su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

cat <<EOF | sudo tee /etc/sysctl.d/99-neutron.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl -p /etc/sysctl.d/99-neutron.conf

sudo systemctl restart \
  nova-api \
  neutron-server \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent \
  neutron-l3-agent
