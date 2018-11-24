#!/bin/sh

##############################################################################
# Install Nova on Controller host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  nova-api \
  nova-conductor \
  nova-consoleauth \
  nova-consoleproxy \
  nova-scheduler

cat > /var/lib/openstack/nova.sql << EOF
CREATE DATABASE nova_api;
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';
EOF
mysql --user=root --password=${ROOT_DBPASS} < /var/lib/openstack/nova.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=nova --password=$NOVA_DBPASS nova_api
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=nova --password=$NOVA_DBPASS nova

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
  compute public http://${CONTROLLER_FQDN}:8774/v2.1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  compute internal http://${CONTROLLER_FQDN}:8774/v2.1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  compute admin http://${CONTROLLER_FQDN}:8774/v2.1/%\(tenant_id\)s

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
firewall_driver = nova.virt.firewall.NoopFirewallDriver
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
auth_strategy = keystone

[api_database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova_api

[barbican]

[cache]

[cells]

[cinder]
os_region_name = RegionOne

[cloudpipe]

[conductor]

[cors]

[cors.subdomain]

[crypto]

[database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova

[ephemeral_storage_encryption]

[glance]
api_servers = http://${CONTROLLER_FQDN}:9292

[guestfs]

[hyperv]

[image_file_url]

[ironic]

[key_manager]

[keystone_authtoken]
auth_uri = https://${CONTROLLER_FQDN}:5000
auth_url = https://${CONTROLLER_FQDN}:35357
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
metadata_proxy_shared_secret = $METADATA_PROXY_SHARED_SECRET
auth_type = password
auth_url = https://${CONTROLLER_FQDN}:35357
project_name = service
project_domain_name = Default
username = neutron
user_domain_name = Default
password = $NEUTRON_PASS

[osapi_v21]

[oslo_concurrency]
lock_path = /var/lock/nova

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[placement]

[placement_database]

[rdp]

[remote_debug]

[serial_console]

[spice]

[ssl]

[trusted_computing]

[upgrade_levels]

[vmware]

[vnc]
vncserver_listen = \$my_ip
vncserver_proxyclient_address = \$my_ip

[workarounds]

[wsgi]

[xenserver]

[xvp]
EOF
chmod 0640 /etc/nova/nova.conf
chown nova:nova /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage db sync" nova

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
firewall_driver = nova.virt.firewall.NoopFirewallDriver
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
auth_strategy = keystone

[api_database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova_api

[barbican]

[cache]

[cells]

[cinder]
os_region_name = RegionOne

[cloudpipe]

[conductor]

[cors]

[cors.subdomain]

[crypto]

[database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova

[ephemeral_storage_encryption]

[glance]
api_servers = http://${CONTROLLER_FQDN}:9292

[guestfs]

[hyperv]

[image_file_url]

[ironic]

[key_manager]

[keystone_authtoken]
auth_uri = https://${CONTROLLER_FQDN}:5000
auth_url = https://${CONTROLLER_FQDN}:35357
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
metadata_proxy_shared_secret = ${METADATA_PROXY_SHARED_SECRET}
auth_type = password
auth_url = https://${CONTROLLER_FQDN}:35357
project_name = service
project_domain_name = Default
username = neutron
user_domain_name = Default
password = ${NEUTRON_PASS}

[osapi_v21]

[oslo_concurrency]
lock_path = /var/lock/nova

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[placement]

[placement_database]

[rdp]

[remote_debug]

[serial_console]

[spice]

[ssl]

[trusted_computing]

[upgrade_levels]

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
EOF
chmod 0640 /etc/nova/nova.conf
chown nova:nova /etc/nova/nova.conf

modprobe nbd
echo nbd > /etc/modules-load.d/nbd.conf

systemctl restart \
  nova-compute
