#!/bin/sh

##############################################################################
# Install Nova on Controller host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  nova-api \
  nova-conductor \
  nova-console \
  nova-consoleauth \
  nova-novncproxy \
  nova-scheduler \
  nova-placement-api

cat > /var/lib/openstack/nova.sql << EOF
CREATE DATABASE nova_api;
CREATE DATABASE nova;
CREATE DATABASE nova_cell0;
CREATE DATABASE placement;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY '${PLACEMENT_DBPASS}';
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY '${PLACEMENT_DBPASS}';
EOF
mysql --user=root --password=${ROOT_DBPASS} < /var/lib/openstack/nova.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=nova --password=$NOVA_DBPASS nova_api
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=nova --password=$NOVA_DBPASS nova
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=nova --password=$NOVA_DBPASS nova_cell0
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=placement --password=$PLACEMENT_DBPASS placement

openstack user create \
  --domain default \
  --password $NOVA_PASS \
  nova
openstack role add \
  --project service \
  --user nova \
  admin
openstack service create \
  --name nova \
  --description "OpenStack Compute" \
  compute
openstack endpoint create \
  --region RegionOne \
  compute public http://${CONTROLLER_FQDN}:8774/v2.1
openstack endpoint create \
  --region RegionOne \
  compute internal http://${CONTROLLER_FQDN}:8774/v2.1
openstack endpoint create \
  --region RegionOne \
  compute admin http://${CONTROLLER_FQDN}:8774/v2.1

openstack user create \
  --domain default \
  --password $PLACEMENT_PASS \
  placement
openstack role add \
  --project service \
  --user placement \
  admin
openstack service create \
  --name placement \
  --description "Placement API" \
  placement
openstack endpoint create \
  --region RegionOne \
  placement public http://${CONTROLLER_FQDN}:8778
openstack endpoint create \
  --region RegionOne \
  placement internal http://${CONTROLLER_FQDN}:8778
openstack endpoint create \
  --region RegionOne \
  placement admin http://${CONTROLLER_FQDN}:8778

usermod -a -G ssl-cert nova

mv /etc/nova/nova.conf /etc/nova/nova.conf.org
cat > /etc/nova/nova.conf << EOF
[DEFAULT]
default_floating_pool = ext-nat
my_ip = ${CONTROLLER_IP_ADDRESS}
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
use_neutron = True
pybasedir = /usr/lib/python2.7/dist-packages
bindir = /usr/bin
state_path = /var/lib/nova
log_dir = /var/log/nova
lock_path = /var/lock/nova
state_path = /var/lib/nova
firewall_driver = nova.virt.firewall.NoopFirewallDriver
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
auth_strategy = keystone

[api]

[api_database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova_api

[barbican]

[cache]

[cells]
enable = False

[cinder]
os_region_name = RegionOne

[compute]

[conductor]

[console]

[consoleauth]

[cors]

[crypto]

[database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova

[devices]

[ephemeral_storage_encryption]

[filter_scheduler]

[glance]
api_servers = http://${CONTROLLER_FQDN}:9292

[healthcheck]

[guestfs]

[hyperv]

[image_file_url]

[ironic]

[key_manager]

[keystone]

[keystone_authtoken]
www_authenticate_uri = https://${CONTROLLER_FQDN}:5000
auth_url = https://${CONTROLLER_FQDN}:5000
certfile = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
keyfile = /etc/ssl/private/${CONTROLLER_FQDN}.key
cafile = /etc/ssl/certs/${SSL_CA_NAME}.pem
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = $NOVA_PASS
auth_type = password

[libvirt]

[matchmaker_redis]

[metrics]

[mks]

[neutron]
url = http://${CONTROLLER_FQDN}:9696
region_name = RegionOne
service_metadata_proxy = True
METADATA_SECRET = $METADATA_SECRET
auth_type = password
auth_url = https://${CONTROLLER_FQDN}:5000
project_name = service
project_domain_name = Default
username = neutron
user_domain_name = Default
password = $NEUTRON_PASS

[notifications]

[osapi_v21]

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[pci]

[placement]
os_region_name = openstack
auth_type = password
auth_url = https://${CONTROLLER_FQDN}:5000/v3
certfile = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
keyfile = /etc/ssl/private/${CONTROLLER_FQDN}.key
cafile = /etc/ssl/certs/${SSL_CA_NAME}.pem
region_name = RegionOne
project_name = service
project_domain_name = Default
username = placement
user_domain_name = Default
password = ${PLACEMENT_PASS}

[placement_database]
connection = mysql+pymysql://placement:${PLACEMENT_DBPASS}@${CONTROLLER_FQDN}/placement

[powervm]

[profiler]

[quota]

[rdp]

[remote_debug]

[scheduler]
discover_hosts_in_cells_interval = 300

[serial_console]

[service_user]

[spice]

[upgrade_levels]

[vault]

[vendordata_dynamic_auth]

[vmware]

[vnc]
vncserver_listen = \$my_ip
vncserver_proxyclient_address = \$my_ip

[workarounds]

[wsgi]

[xenserver]

[xvp]

[zvm]

EOF
chmod 0640 /etc/nova/nova.conf
chown nova:nova /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova

sed -i 's/^NOVA_CONSOLE_PROXY_TYPE=.*/NOVA_CONSOLE_PROXY_TYPE=novnc/' /etc/default/nova-consoleproxy

systemctl restart \
  nova-api \
  nova-consoleauth \
  nova-scheduler \
  nova-conductor \
  nova-novncproxy

openstack compute service list

##############################################################################
# Install Nova on Compute host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet nova-compute

usermod -a -G ssl-cert nova

# Overwrite existing /etc/nova/nova.conf if controller host is also compute host
mv /etc/nova/nova.conf /etc/nova/nova.conf.org
cat > /etc/nova/nova.conf << EOF
[DEFAULT]
default_floating_pool = ext-nat
my_ip = ${COMPUTE_IP_ADDRESS}
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
use_neutron = True
pybasedir = /usr/lib/python2.7/dist-packages
bindir = /usr/bin
state_path = /var/lib/nova
log_dir = /var/log/nova
lock_path = /var/lock/nova
state_path = /var/lib/nova
firewall_driver = nova.virt.firewall.NoopFirewallDriver
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
auth_strategy = keystone

[api]

[api_database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova_api

[barbican]

[cache]

[cells]
enable = False

[cinder]
os_region_name = RegionOne

[compute]

[conductor]

[console]

[consoleauth]

[cors]

[crypto]

[database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova

[devices]

[ephemeral_storage_encryption]

[filter_scheduler]

[glance]
api_servers = http://${CONTROLLER_FQDN}:9292

[healthcheck]

[guestfs]

[hyperv]

[image_file_url]

[ironic]

[key_manager]

[keystone]

[keystone_authtoken]
www_authenticate_uri = https://${CONTROLLER_FQDN}:5000
auth_url = https://${CONTROLLER_FQDN}:5000
certfile = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
keyfile = /etc/ssl/private/${CONTROLLER_FQDN}.key
cafile = /etc/ssl/certs/${SSL_CA_NAME}.pem
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = $NOVA_PASS
auth_type = password

[libvirt]

[matchmaker_redis]

[metrics]

[mks]

[neutron]
url = http://${CONTROLLER_FQDN}:9696
region_name = RegionOne
service_metadata_proxy = True
METADATA_SECRET = ${METADATA_SECRET}
auth_type = password
auth_url = https://${CONTROLLER_FQDN}:5000
project_name = service
project_domain_name = Default
username = neutron
user_domain_name = Default
password = ${NEUTRON_PASS}

[notifications]

[osapi_v21]

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[pci]

[placement]
os_region_name = openstack
auth_type = password
auth_url = https://${CONTROLLER_FQDN}:5000/v3
certfile = /etc/ssl/certs/${CONTROLLER_FQDN}.crt
keyfile = /etc/ssl/private/${CONTROLLER_FQDN}.key
cafile = /etc/ssl/certs/${SSL_CA_NAME}.pem
region_name = RegionOne
project_name = service
project_domain_name = Default
username = placement
user_domain_name = Default
password = ${PLACEMENT_PASS}

[placement_database]
connection = mysql+pymysql://placement:${PLACEMENT_DBPASS}@${CONTROLLER_FQDN}/placement

[powervm]

[profiler]

[quota]

[rdp]

[remote_debug]

[scheduler]
discover_hosts_in_cells_interval = 300

[serial_console]

[service_user]

[spice]

[upgrade_levels]

[vault]

[vendordata_dynamic_auth]

[vmware]

[vnc]
enabled = True
vncserver_listen = \$my_ip
vncserver_proxyclient_address = \$my_ip
novncproxy_base_url = http://${CONTROLLER_FQDN}:6080/vnc_auto.html
xvpvncproxy_base_url=http://${CONTROLLER_FQDN}:6081/console

[workarounds]

[wsgi]

[xenserver]

[xvp]

[zvm]

EOF
chmod 0640 /etc/nova/nova.conf
chown nova:nova /etc/nova/nova.conf

modprobe nbd
echo nbd > /etc/modules-load.d/nbd.conf

systemctl restart \
  nova-compute

openstack compute service list \
  --service nova-compute

su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

openstack compute service list
openstack catalog list
