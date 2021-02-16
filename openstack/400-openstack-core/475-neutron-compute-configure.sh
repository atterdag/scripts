#!/bin/bash

##############################################################################
# Configure Neutron on Compute host
##############################################################################
# Don't overwrite if controller node is also compute node
if [[ $CONTROLLER_FQDN != $COMPUTE_FQDN ]]; then
  sudo crudini --set /etc/neutron/neutron.conf DEFAULT transport_url "rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}:5671/?ssl=1"
  sudo crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy "keystone"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type "password"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name "default"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name "default"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name "service"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken username "neutron"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken password "$NEUTRON_PASS"
  sudo crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path "/var/lib/neutron/tmp"
  sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings "${OS_OS_COMPUTE_PROVIDER_VIRTUAL_NIC}:${OS_COMPUTE_PROVIDER_PHYSICAL_NIC}"
  sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan "true"
  sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip "${OS_COMPUTE_IP_ADDRESS}"
  sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population "true"
  sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group "true"
  sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver "neutron.agent.linux.iptables_firewall.IptablesFirewallDriver"
  sudo crudini --set /etc/nova/nova.conf neutron auth_url "https://${CONTROLLER_FQDN}:5000"
  sudo crudini --set /etc/nova/nova.conf neutron auth_type "password"
  sudo crudini --set /etc/nova/nova.conf neutron project_domain_name "Default"
  sudo crudini --set /etc/nova/nova.conf neutron user_domain_name "Default"
  sudo crudini --set /etc/nova/nova.conf neutron region_name "RegionOne"
  sudo crudini --set /etc/nova/nova.conf neutron project_name "service"
  sudo crudini --set /etc/nova/nova.conf neutron username "neutron"
  sudo crudini --set /etc/nova/nova.conf neutron password "${NEUTRON_PASS}"

  # Own additions
  sudo crudini --set /etc/neutron/neutron.conf DEFAULT debug "false"
  sudo crudini --set /etc/neutron/neutron.conf DEFAULT syslog_log_facility "LOG_LOCAL0"
  sudo crudini --set /etc/neutron/neutron.conf DEFAULT use_syslog "true"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken cafile "/etc/ssl/certs/ca-certificates.crt"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken certfile "/etc/ssl/certs/${COMPUTE_FQDN}.crt"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken keyfile "/etc/ssl/private/${COMPUTE_FQDN}.key"
  sudo crudini --set /etc/neutron/neutron.conf keystone_authtoken region_name "RegionOne"
  sudo crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge bridge_mappings "${OS_OS_COMPUTE_PROVIDER_VIRTUAL_NIC}:${OS_COMPUTE_PROVIDER_PHYSICAL_NIC}"
  # sudo crudini --set /etc/nova/nova.conf neutron METADATA_SECRET "${METADATA_SECRET}"
  # sudo crudini --set /etc/nova/nova.conf neutron service_metadata_proxy "true"

  sudo chmod 0660 \
    /etc/neutron/neutron.conf
  sudo chown neutron:neutron \
    /etc/neutron/neutron.conf

  sudo usermod -a -G ssl-cert neutron

  cat <<EOF | sudo tee /etc/sysctl.d/99-neutron.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
  sudo sysctl -p /etc/sysctl.d/99-neutron.conf

  sudo systemctl restart \
    nova-compute \
    neutron-linuxbridge-agent
fi
