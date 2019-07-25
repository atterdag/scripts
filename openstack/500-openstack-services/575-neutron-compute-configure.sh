#!/bin/sh

##############################################################################
# Configure Neutron on Compute host
##############################################################################
# Don't overwrite if controller node is also compute node
sudo mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
cat << EOF | sudo tee /etc/neutron/neutron.conf
[DEFAULT]
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
auth_strategy = keystone

[agent]

[cors]

[cors.subdomain]

[database]

[keystone_authtoken]
www_authenticate_uri = https://${CONTROLLER_FQDN}:5000
auth_url = https://${CONTROLLER_FQDN}:5000
certfile = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
keyfile = /etc/ssl/private/${CONTROLLER_FQDN}.key
cafile = /etc/ssl/certs/ca-certificates.crt
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = neutron
password = $NEUTRON_PASS
auth_type = password

[matchmaker_redis]

[nova]

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_policy]

[qos]

[quotas]

[ssl]
EOF
sudo chmod 0660 /etc/neutron/neutron.conf
sudo chown neutron:neutron /etc/neutron/neutron.conf

# Don't overwrite if controller node is also compute node
sudo mv /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.org
cat << EOF | sudo tee /etc/neutron/plugins/ml2/linuxbridge_agent.ini
[DEFAULT]

[agent]

[linux_bridge]
# Remember to uncomment if using flat networks
; physical_interface_mappings = inside:${NETWORK_INTERFACE}.1,servers:${NETWORK_INTERFACE}.2,dmz:${NETWORK_INTERFACE}.3,outside:${NETWORK_INTERFACE}.4
physical_interface_mappings = ${NETWORK_INTERFACE}:${NETWORK_INTERFACE}
# Remember to uncomment if using flat networks
; bridge_mappings = outside:${NETWORK_INTERFACE}

[securitygroup]
enable_security_group = True
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

[vxlan]
enable_vxlan = False
EOF

sudo usermod -a -G ssl-cert neutron

sudo systemctl restart \
  nova-compute \
  neutron-linuxbridge-agent
