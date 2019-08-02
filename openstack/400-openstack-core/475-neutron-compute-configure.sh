#!/bin/bash

##############################################################################
# Configure Neutron on Compute host
##############################################################################
# Don't overwrite if controller node is also compute node
if [[ $CONTROLLER_FQDN != $COMPUTE_FQDN ]]; then
  sudo crudini --set /etc/neutron/neutron.conf DEFAULT transport_url "rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}"
  sudo crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy "keystone"
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
  sudo crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path "/var/lib/neutron/tmp"
  sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group "True"
  sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver "neutron.agent.linux.iptables_firewall.IptablesFirewallDriver"
  sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan "False"

  sudo chmod 0660 \
    /etc/neutron/neutron.conf
  sudo chown neutron:neutron \
    /etc/neutron/neutron.conf

  # Remember to uncomment if using flat networks
  # sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings "inside:${NETWORK_INTERFACE}.1,servers:${NETWORK_INTERFACE}.2,dmz:${NETWORK_INTERFACE}.3,outside:${NETWORK_INTERFACE}.4"
  # sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge bridge_mappings "outside:${NETWORK_INTERFACE}"

  # or if VLANs are managed by neutron
  sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings "${NETWORK_INTERFACE}:${NETWORK_INTERFACE}"

  sudo usermod -a -G ssl-cert neutron
fi

sudo systemctl restart \
  nova-compute \
  neutron-linuxbridge-agent
