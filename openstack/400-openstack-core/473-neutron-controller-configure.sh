#!/bin/bash

##############################################################################
# Configure Neutron on Controller host
##############################################################################
# If you don't want to let openstack manage which VLANs the neutron networks
# can connect to then uncomment below to change to flat networks, and map all
# openstack networks to specific vlan interfaces in the linuxbridge
# configuration file.
# Run these commands if you want to use flat network
# sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers "flat"
# sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types "flat"
# sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers "linuxbridge"
# sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers "port_security"
# sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 external_network_type "flat"
# sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks "*"
# sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini physical_interface_mappings "inside:${NETWORK_INTERFACE}.1,servers:${NETWORK_INTERFACE}.2,dmz:${NETWORK_INTERFACE}.3,outside:${NETWORK_INTERFACE}.4"
# sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini physical_interface_mappings physical_interface_mappings "inside:${NETWORK_INTERFACE}.1,servers:${NETWORK_INTERFACE}.2,dmz:${NETWORK_INTERFACE}.3,outside:${NETWORK_INTERFACE}.4"
# sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini physical_interface_mappings bridge_mappings "outside:${NETWORK_INTERFACE}"

# Or run these if you want to let neutorn manage which vlans to connect to
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers "vlan"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types "vlan"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers "linuxbridge"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers "port_security"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 external_network_type "vlan"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges "${NETWORK_INTERFACE}:1:4094"
sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings "${NETWORK_INTERFACE}:${NETWORK_INTERFACE}"

# Run this for either
sudo crudini --set /etc/neutron/neutron.conf DEFAULT nova_metadata_ip "${CONTROLLER_FQDN}"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT METADATA_SECRET "${METADATA_SECRET}"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy "keystone"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin "ml2"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins "router"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT dhcp_agents_per_network "2"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips "True"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes "True"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend "rabbit"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT transport_url "rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy "keystone"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes "True"
sudo crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes "True"
sudo crudini --set /etc/neutron/neutron.conf agent root_helper "sudo neutron-rootwrap /etc/neutron/rootwrap.conf"
sudo crudini --set /etc/neutron/neutron.conf database connection "mysql+pymysql://neutron:${NEUTRON_DBPASS}@${CONTROLLER_FQDN}/neutron"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken certfile "/etc/ssl/certs/${CONTROLLER_FQDN}.crt"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken keyfile "/etc/ssl/private/${CONTROLLER_FQDN}.key"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken cafile "/etc/ssl/certs/ca-certificates.crt"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken region_name "RegionOne"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name "Default"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name "Default"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name "service"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken username "neutron"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken password "$NEUTRON_PASS"
sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type "password"
sudo crudini --set /etc/neutron/neutron.conf nova auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/neutron/neutron.conf nova region_name "RegionOne"
sudo crudini --set /etc/neutron/neutron.conf nova project_domain_name "Default"
sudo crudini --set /etc/neutron/neutron.conf nova project_name "service"
sudo crudini --set /etc/neutron/neutron.conf nova user_domain_name "Default"
sudo crudini --set /etc/neutron/neutron.conf nova username "nova"
sudo crudini --set /etc/neutron/neutron.conf nova password "$NOVA_PASS"
sudo crudini --set /etc/neutron/neutron.conf nova auth_type "password"
sudo crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path "/var/lib/neutron/tmp"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group "True"
sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset "True"
sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group "True"
sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver "neutron.agent.linux.iptables_firewall.IptablesFirewallDriver"
sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan "False"
sudo crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver "neutron.agent.linux.interface.BridgeInterfaceDriver"
sudo crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver "neutron.agent.linux.dhcp.Dnsmasq"
sudo crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata "True"
sudo crudini --set /etc/neutron/metadata_agent.ini DEFAULT ova_metadata_ip "$CONTROLLER_FQDN"
sudo crudini --set /etc/neutron/metadata_agent.ini DEFAULT METADATA_SECRET "$METADATA_SECRET"

sudo chmod 0660 \
  /etc/neutron/neutron.conf \
  /etc/neutron/metadata_agent.ini
sudo chown neutron:neutron \
  /etc/neutron/neutron.conf \
  /etc/neutron/metadata_agent.ini

sudo usermod -a -G ssl-cert neutron

sudo su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

sudo systemctl restart \
  nova-api \
  neutron-server \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent
