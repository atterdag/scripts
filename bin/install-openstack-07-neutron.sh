#!/bin/sh

##############################################################################
# Install Neutron on Controller host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  neutron-server \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent \
  neutron-l3-agent

cat > /var/lib/openstack/neutron.sql << EOF
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '${NEUTRON_DBPASS}';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '${NEUTRON_DBPASS}';
EOF
mysql --user=root --password="${ROOT_DBPASS}" < /var/lib/openstack/neutron.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=neutron --password=$NEUTRON_DBPASS neutron

openstack user create \
  --domain default \
  --password $NEUTRON_PASS \
  neutron
openstack role add \
  --project service \
  --user neutron \
  admin
openstack service create \
  --name neutron \
  --description 'OpenStack Networking' \
  network
openstack endpoint create \
  --region RegionOne \
  network public http://${CONTROLLER_FQDN}:9696
openstack endpoint create \
  --region RegionOne \
  network internal http://${CONTROLLER_FQDN}:9696
openstack endpoint create \
  --region RegionOne \
  network admin http://${CONTROLLER_FQDN}:9696

usermod -a -G ssl-cert neutron

mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
cat > /etc/neutron/neutron.conf << EOF
[DEFAULT]
nova_metadata_ip = ${CONTROLLER_FQDN}
METADATA_SECRET = ${METADATA_SECRET}
auth_strategy = keystone
core_plugin = ml2
service_plugins =
dhcp_agents_per_network = 2
allow_overlapping_ips = True
notify_nova_on_port_status_changes = True
rpc_backend = rabbit
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
auth_strategy = keystone
notify_nova_on_port_status_changes = True
notify_nova_on_port_data_changes = True
dns_domain = ${DNS_DOMAIN}.

[agent]
root_helper = sudo neutron-rootwrap /etc/neutron/rootwrap.conf

[cors]

[cors.subdomain]

[database]
connection = mysql+pymysql://neutron:${NEUTRON_DBPASS}@${CONTROLLER_FQDN}/neutron

[keystone_authtoken]
auth_uri = https://${CONTROLLER_FQDN}:5000
auth_url = https://${CONTROLLER_FQDN}:5000
certfile = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
keyfile = /etc/ssl/private/${CONTROLLER_FQDN}.key
cafile = /etc/ssl/certs/${SSL_CA_NAME}.pem
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
auth_url = https://${CONTROLLER_FQDN}:5000
region_name = RegionOne
project_domain_name = Default
project_name = service
user_domain_name = Default
username = nova
password = $NOVA_PASS
auth_type = password

[oslo_concurrency]
lock_path = /var/lock/neutron

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_policy]

[qos]

[quotas]

[ssl]
EOF
chmod 0660 /etc/neutron/neutron.conf
chown neutron:neutron /etc/neutron/neutron.conf

mv /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.org
cat > /etc/neutron/plugins/ml2/ml2_conf.ini << EOF
[DEFAULT]

[ml2]
# If you don't want to let openstack manage which VLANs the neutron networks
# can connect to then uncomment below to change to flat networks, and map all
# openstack networks to specific vlan interfaces in the linuxbridge
# configuration file.
; type_drivers = flat
; tenant_network_types = flat
; mechanism_drivers = linuxbridge
; extension_drivers = port_security,dns
; external_network_type = flat
type_drivers = vlan
tenant_network_types = vlan
mechanism_drivers = linuxbridge
extension_drivers = port_security,dns
external_network_type = vlan

[ml2_type_flat]
# Remember to uncomment if using flat networks
; flat_networks = *

[ml2_type_geneve]

[ml2_type_gre]

[ml2_type_vlan]
# Remember to comment if using flat networks
network_vlan_ranges = ${NETWORK_INTERFACE}:1:4094

[ml2_type_vxlan]

[securitygroup]
enable_security_group = True
enable_ipset = True
EOF

mv /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.org
cat > /etc/neutron/plugins/ml2/linuxbridge_agent.ini << EOF
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

mv /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.org
cat > /etc/neutron/dhcp_agent.ini << EOF
[DEFAULT]
interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = True

[AGENT]
EOF

mv /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini.org
cat > /etc/neutron/metadata_agent.ini << EOF
[DEFAULT]
ova_metadata_ip = $CONTROLLER_FQDN
METADATA_SECRET = $METADATA_SECRET
[AGENT]

[cache]
EOF
chmod 0640 /etc/neutron/metadata_agent.ini
chown neutron:neutron /etc/neutron/metadata_agent.ini

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

systemctl restart \
  nova-api \
  neutron-server \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent

##############################################################################
# Install Neutron on Compute host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet neutron-linuxbridge-agent

usermod -a -G ssl-cert neutron

# Don't overwrite if controller node is also compute node
mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
cat > /etc/neutron/neutron.conf << EOF
[DEFAULT]
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
auth_strategy = keystone

[agent]

[cors]

[cors.subdomain]

[database]

[keystone_authtoken]
auth_uri = https://${CONTROLLER_FQDN}:5000
auth_url = https://${CONTROLLER_FQDN}:5000
certfile = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
keyfile = /etc/ssl/private/${CONTROLLER_FQDN}.key
cafile = /etc/ssl/certs/${SSL_CA_NAME}.pem
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
lock_path = /var/lock/neutron

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_policy]

[qos]

[quotas]

[ssl]
EOF
chmod 0660 /etc/neutron/neutron.conf
chown neutron:neutron /etc/neutron/neutron.conf

# Don't overwrite if controller node is also compute node
mv /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.org
cat > /etc/neutron/plugins/ml2/linuxbridge_agent.ini << EOF
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

systemctl restart \
  nova-compute \
  neutron-linuxbridge-agent

neutron ext-list
openstack network agent list
