#!/bin/sh
##############################################################################
# Remove previous packages on all
##############################################################################
apt-get --yes --purge remove mysql-common apache2 python-openstack* rabbitmq-server chrony memcached qemu-kvm qemu-slof qemu-system-common qemu-system-x86 qemu-utils sphinx-common python-memcache
apt-get --yes --purge autoremove
for i in $(pip list | awk '{print $1}'); do pip uninstall -y $i; done
apt-get --reinstall install $(echo $(dpkg -l | awk '{print $2}' | tail -n +5 | grep ^python-) | sed 's|\n| |g')

##############################################################################
# Install NTP on Controller
##############################################################################
apt install -y chrony

mv /etc/chrony/chrony.conf /etc/chrony/chrony.conf.org

cat >> /etc/chrony/chrony.conf << EOT
allow 172.16.226.0/24
EOT

cat > /etc/chrony/chrony.conf << EOT
server 172.16.226.121
EOT


systemctl restart chrony

##############################################################################
# Install OpenStack command line tool on Controller
##############################################################################
apt install -y python-openstackclient

# pip install python-openstackclient
# pip install python-barbicanclient
# pip install python-ceilometerclient
# pip install python-cinderclient
# pip install python-cloudkittyclient
# pip install python-designateclient
# pip install python-fuelclient
# pip install python-glanceclient
# pip install python-gnocchiclient
# pip install python-heatclient
# pip install python-magnumclient
# pip install python-manilaclient
# pip install python-mistralclient
# pip install python-monascaclient
# pip install python-muranoclient
# pip install python-neutronclient
# pip install python-novaclient
# pip install python-saharaclient
# pip install python-senlinclient
# pip install python-swiftclient
# pip install python-troveclient

##############################################################################
# Install Database on Controller
##############################################################################
apt install -y mysql-server python-pymysql

cat > /etc/mysql/mariadb.conf.d/99-openstack.cnf << EOF
[mysqld]
bind-address = 172.16.226.121

default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
systemctl restart mysql

##############################################################################
# Install Queue Manager on Controller
##############################################################################
apt install -y rabbitmq-server
rabbitmqctl add_user openstack 'CebrOssImyaufsay'
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

##############################################################################
# Install Memcached on Controller
##############################################################################
apt install -y memcached python-memcache
sed -i 's/-l\s127\.0\.0\.1/-l 172.16.226.121/' /etc/memcached.conf
systemctl restart memcached

##############################################################################
# Install Apache on Controller
##############################################################################
apt install -y apache2
echo "ServerName os-con-1.example.com" > /etc/apache2/conf-available/servername.conf
a2enconf servername
systemctl restart apache2

##############################################################################
# Install Keystone on Controller
##############################################################################
DEBIAN_FRONTEND=noninteractive apt install -yq keystone

systemctl restart apache2

cat > keystone.sql << EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '0n7W1llITSDU';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '0n7W1llITSDU';
exit
EOF
mysql --user=root --password="Mw&slwbt" < keystone.sql
mysqldump --host=os-con-1.example.com --port=3306 --user=keystone --password=0n7W1llITSDU keystone

# admin_token = S7Usn3DDYSiD

mv /etc/keystone/keystone.conf /etc/keystone/keystone.conf.org
cat > /etc/keystone/keystone.conf << EOF
[DEFAULT]
log_file = keystone.log
log_dir = /var/log/keystone

[assignment]

[auth]

[cache]

[catalog]
template_file = /etc/keystone/default_catalog.templates

[cors]

[cors.subdomain]

[credential]

[database]
connection = mysql+pymysql://keystone:0n7W1llITSDU@os-con-1.example.com/keystone

[domain_config]

[endpoint_filter]

[endpoint_policy]

[eventlet_server]

[federation]

[fernet_tokens]

[identity]

[identity_mapping]

[kvs]

[ldap]

[matchmaker_redis]

[memcache]

[oauth1]

[os_inherit]

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[paste_deploy]

[policy]

[profiler]

[resource]

[revoke]

[role]

[saml]

[security_compliance]

[shadow_users]

[signing]

[token]
provider = fernet

[tokenless_auth]

[trust]
EOF

su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage bootstrap --bootstrap-password MedIE5ESSKSH \
  --bootstrap-admin-url http://os-con-1.example.com:35357/v3/ \
  --bootstrap-internal-url http://os-con-1.example.com:35357/v3/ \
  --bootstrap-public-url http://os-con-1.example.com:5000/v3/ \
  --bootstrap-region-id RegionOne

export OS_USERNAME=admin
export OS_PASSWORD=MedIE5ESSKSH
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://os-con-1.example.com:35357/v3
export OS_IDENTITY_API_VERSION=3

openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password passw0rd demo
openstack role create user
openstack role add --project demo --user demo user

unset OS_AUTH_URL OS_PASSWORD
openstack --os-auth-url http://os-con-1.example.com:35357/v3 \
  --os-project-domain-name Default --os-user-domain-name Default \
  --os-project-name admin --os-username admin token issue \
  --os-password MedIE5ESSKSH

openstack --os-auth-url http://os-con-1.example.com:35357/v3 \
  --os-project-domain-name Default --os-user-domain-name Default \
  --os-project-name demo --os-username demo token issue \
  --os-password passw0rd

cat > admin-openrc << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=MedIE5ESSKSH
export OS_AUTH_URL=http://os-con-1.example.com:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

cat > demo-openrc << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=passw0rd
export OS_AUTH_URL=http://os-con-1.example.com:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

source admin-openrc

openstack token issue

##############################################################################
# Install Glance on Controller
##############################################################################
DEBIAN_FRONTEND=noninteractive apt install -yq glance

cat > glance.sql << EOF
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'oajsailNaihephFu';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'oajsailNaihephFu';
exit
EOF
mysql --user=root --password="Mw&slwbt" < glance.sql
mysqldump --host=os-con-1.example.com --port=3306 --user=glance --password='oajsailNaihephFu' glance

openstack user create --domain default --password 'oajsailNaihephFu' glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://os-con-1.example.com:9292
openstack endpoint create --region RegionOne image internal http://os-con-1.example.com:9292
openstack endpoint create --region RegionOne image admin http://os-con-1.example.com:9292

mv /etc/glance/glance-api.conf /etc/glance/glance-api.conf.org
cat > /etc/glance/glance-api.conf << EOF
[DEFAULT]

[cors]

[cors.subdomain]

[database]
connection = mysql+pymysql://glance:oajsailNaihephFu@os-con-1.example.com/glance

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images

[image_format]

[keystone_authtoken]
auth_uri = http://os-con-1.example.com:5000
auth_url = http://os-con-1.example.com:35357
region_name = RegionOne
memcached_servers = os-con-1.example.com:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = oajsailNaihephFu
auth_type = password

[matchmaker_redis]

[oslo_concurrency]
lock_path = /var/lock/glance

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_policy]

[paste_deploy]
flavor = keystone

[profiler]

[store_type_location_strategy]

[task]

[taskflow_executor]
EOF

mv /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.org
cat > /etc/glance/glance-registry.conf << EOF
[DEFAULT]

[database]
connection = mysql+pymysql://glance:oajsailNaihephFu@os-con-1.example.com/glance

[glance_store]
filesystem_store_datadir = /var/lib/glance/images

[keystone_authtoken]
auth_uri = http://os-con-1.example.com:5000
auth_url = http://os-con-1.example.com:35357
region_name = RegionOne
memcached_servers = os-con-1.example.com:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = oajsailNaihephFu
auth_type = password

[matchmaker_redis]

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_policy]

[paste_deploy]
flavor = keystone

[profiler]
EOF

su -s /bin/sh -c "glance-manage db_sync" glance

systemctl restart glance-registry
systemctl restart glance-api

wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
openstack image create "cirros" \
  --file cirros-0.3.4-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public

openstack image list

##############################################################################
# Install Nova on Controller
##############################################################################
DEBIAN_FRONTEND=noninteractive apt install -yq nova-api nova-conductor nova-consoleauth nova-consoleproxy nova-scheduler

cat > nova.sql << EOF
CREATE DATABASE nova_api;
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'ArSeRCatin6E';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'ArSeRCatin6E';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'ArSeRCatin6E';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'ArSeRCatin6E';
EOF
mysql --user=root --password="Mw&slwbt" < nova.sql
mysqldump --host=os-con-1.example.com --port=3306 --user=nova --password=ArSeRCatin6E nova_api
mysqldump --host=os-con-1.example.com --port=3306 --user=nova --password=ArSeRCatin6E nova

openstack user create --domain default --password ArSeRCatin6E nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://os-con-1.example.com:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://os-con-1.example.com:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://os-con-1.example.com:8774/v2.1/%\(tenant_id\)s

mv /etc/nova/nova.conf /etc/nova/nova.conf.org
cat > /etc/nova/nova.conf << EOF
[DEFAULT]
default_floating_pool = ext-nat
my_ip = 172.16.226.121
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
use_neutron = True
pybasedir = /usr/lib/python2.7/dist-packages
bindir = /usr/bin
state_path = /var/lib/nova
firewall_driver = nova.virt.firewall.NoopFirewallDriver
transport_url = rabbit://openstack:CebrOssImyaufsay@os-con-1.example.com
auth_strategy = keystone

[api_database]
connection = mysql+pymysql://nova:ArSeRCatin6E@os-con-1.example.com/nova_api

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
connection = mysql+pymysql://nova:ArSeRCatin6E@os-con-1.example.com/nova

[ephemeral_storage_encryption]

[glance]
api_servers = http://os-con-1.example.com:9292

[guestfs]

[hyperv]

[image_file_url]

[ironic]

[key_manager]

[keystone_authtoken]
auth_uri = http://os-con-1.example.com:5000
auth_url = http://os-con-1.example.com:35357
region_name = RegionOne
memcached_servers = os-con-1.example.com:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = ArSeRCatin6E
auth_type = password

[libvirt]

[matchmaker_redis]

[metrics]

[mks]

[neutron]
url = http://os-con-1.example.com:9696
region_name = RegionOne
service_metadata_proxy = True
metadata_proxy_shared_secret = mATIN60manTE
auth_type = password
auth_url = http://os-con-1.example.com:35357
project_name = service
project_domain_name = Default
username = neutron
user_domain_name = Default
password = blec3lgOOD5l

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
server_listen = 0.0.0.0
server_proxyclient_address = \$my_ip
enabled = true

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

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage db sync" nova

service nova-api restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

openstack compute service list

##############################################################################
# Install Nova on Host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt install -yq nova-compute

mv /etc/nova/nova.conf /etc/nova/nova.conf.org
cat > /etc/nova/nova.conf << EOF
[DEFAULT]
default_floating_pool = ext-nat
my_ip = 172.16.226.121
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
use_neutron = True
pybasedir = /usr/lib/python2.7/dist-packages
bindir = /usr/bin
state_path = /var/lib/nova
firewall_driver = nova.virt.firewall.NoopFirewallDriver
transport_url = rabbit://openstack:CebrOssImyaufsay@os-con-1.example.com
auth_strategy = keystone

[api_database]
connection = mysql+pymysql://nova:ArSeRCatin6E@os-con-1.example.com/nova_api

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
connection = mysql+pymysql://nova:ArSeRCatin6E@os-con-1.example.com/nova

[ephemeral_storage_encryption]

[glance]
api_servers = http://os-con-1.example.com:9292

[guestfs]

[hyperv]

[image_file_url]

[ironic]

[key_manager]

[keystone_authtoken]
auth_uri = http://os-con-1.example.com:5000
auth_url = http://os-con-1.example.com:35357
region_name = RegionOne
memcached_servers = os-con-1.example.com:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = ArSeRCatin6E
auth_type = password

[libvirt]

[matchmaker_redis]

[metrics]

[mks]

[neutron]
url = http://os-con-1.example.com:9696
region_name = RegionOne
service_metadata_proxy = True
metadata_proxy_shared_secret = mATIN60manTE
auth_type = password
auth_url = http://os-con-1.example.com:35357
project_name = service
project_domain_name = Default
username = neutron
user_domain_name = Default
password = blec3lgOOD5l

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
server_listen = 0.0.0.0
server_proxyclient_address = \$my_ip
enabled = true

[ssl]

[trusted_computing]

[upgrade_levels]

[vmware]

[vnc]
enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = \$my_ip
novncproxy_base_url = http://os-con-1.example.com:6080/vnc_auto.html

[workarounds]

[wsgi]

[xenserver]

[xvp]
EOF

modprobe nbd
echo nbd > /etc/modules-load.d/nbd.conf

service nova-compute restart

##############################################################################
# Install Neutron on Controller
##############################################################################
DEBIAN_FRONTEND=noninteractive apt install -yq neutron-server neutron-linuxbridge-agent neutron-dhcp-agent neutron-metadata-agent neutron-l3-agent

cat > neutron.sql << EOF
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'blec3lgOOD5l';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'blec3lgOOD5l';
EOF
mysql --user=root --password="Mw&slwbt" < neutron.sql
mysqldump --host=os-con-1.example.com --port=3306 --user=neutron --password=blec3lgOOD5l neutron

openstack user create --domain default --password blec3lgOOD5l neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://os-con-1.example.com:9696
openstack endpoint create --region RegionOne network internal http://os-con-1.example.com:9696
openstack endpoint create --region RegionOne network admin http://os-con-1.example.com:9696

mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
cat > /etc/neutron/neutron.conf << EOF
[DEFAULT]
nova_metadata_ip = os-con-1.example.com
metadata_proxy_shared_secret = mATIN60manTE
auth_strategy = keystone
core_plugin = ml2
service_plugins =
allow_overlapping_ips = True
notify_nova_on_port_status_changes = True
rpc_backend = rabbit
transport_url = rabbit://openstack:CebrOssImyaufsay@os-con-1.example.com
auth_strategy = keystone
notify_nova_on_port_status_changes = True
notify_nova_on_port_data_changes = True

[agent]
root_helper = sudo neutron-rootwrap /etc/neutron/rootwrap.conf

[cors]

[cors.subdomain]

[database]
connection = mysql+pymysql://neutron:blec3lgOOD5l@os-con-1.example.com/neutron

[keystone_authtoken]
auth_uri = http://os-con-1.example.com:5000
auth_url = http://os-con-1.example.com:35357
region_name = RegionOne
memcached_servers = os-con-1.example.com:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = neutron
password = blec3lgOOD5l
auth_type = password

[matchmaker_redis]

[nova]
auth_url = http://os-con-1.example.com:35357
region_name = regionOne
project_domain_name = Default
project_name = service
user_domain_name = Default
username = nova
password = ArSeRCatin6E
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

mv /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.org
cat > /etc/neutron/plugins/ml2/ml2_conf.ini << EOF
[DEFAULT]

[ml2]
type_drivers = flat,vlan
tenant_network_types =
mechanism_drivers = linuxbridge
extension_drivers = port_security

[ml2_type_flat]
flat_networks = provider

[ml2_type_geneve]

[ml2_type_gre]

[ml2_type_vlan]

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
physical_interface_mappings = provider:eth1

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
ova_metadata_ip = os-con-1.example.com
metadata_proxy_shared_secret = mATIN60manTE
[AGENT]

[cache]
EOF

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

service nova-api restart
service neutron-server restart
service neutron-linuxbridge-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart

##############################################################################
# Install Neutron on Host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt install -yq neutron-linuxbridge-agent

mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
cat > /etc/neutron/neutron.conf << EOF
[DEFAULT]
transport_url = rabbit://openstack:CebrOssImyaufsay@os-con-1.example.com
auth_strategy = keystone

[agent]

[cors]

[cors.subdomain]

[database]

[keystone_authtoken]
auth_uri = http://os-con-1.example.com:5000
auth_url = http://os-con-1.example.com:35357
region_name = RegionOne
memcached_servers = os-con-1.example.com:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = neutron
password = blec3lgOOD5l
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

mv /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.org
cat > /etc/neutron/plugins/ml2/linuxbridge_agent.ini << EOF
[DEFAULT]

[agent]

[linux_bridge]
physical_interface_mappings = provider:eth1

[securitygroup]
enable_security_group = True
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

[vxlan]
enable_vxlan = False
EOF

service nova-compute restart
service neutron-linuxbridge-agent restart

neutron ext-list
openstack network agent list

##############################################################################
# Install Horizon on Controller
##############################################################################
DEBIAN_FRONTEND=noninteractive apt install -yq openstack-dashboard-apache

mv /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.py.org
cat >  /etc/openstack-dashboard/local_settings.py << EOF
import os
from django.utils.translation import ugettext_lazy as _
from horizon.utils import secret_key
from openstack_dashboard import exceptions
from openstack_dashboard.settings import HORIZON_CONFIG
DEBUG = True
WEBROOT = '/horizon'
ALLOWED_HOSTS = ['*', ]
OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 2,
}
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
LOCAL_PATH = os.path.dirname(os.path.abspath(__file__))
SECRET_KEY = secret_key.generate_or_read_from_file(
    os.path.join("/","var","lib","openstack-dashboard","secret-key", '.secret_key_store'))
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': 'os-con-1.example.com:11211',
    },
}
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
OPENSTACK_HOST = "os-con-1.example.com"
OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "_member_"
OPENSTACK_KEYSTONE_BACKEND = {
    'name': 'native',
    'can_edit_user': True,
    'can_edit_group': True,
    'can_edit_project': True,
    'can_edit_domain': True,
    'can_edit_role': True,
}
OPENSTACK_HYPERVISOR_FEATURES = {
    'can_set_mount_point': False,
    'can_set_password': False,
    'requires_keypair': False,
    'enable_quotas': True
}
OPENSTACK_CINDER_FEATURES = {
    'enable_backup': False,
}
OPENSTACK_NEUTRON_NETWORK = {
    'enable_router': False,
    'enable_quotas': False,
    'enable_ipv6': False,
    'enable_distributed_router': False,
    'enable_ha_router': False,
    'enable_lb': False,
    'enable_firewall': False,
    'enable_vpn': False,
    'enable_fip_topology_check': False,
    'profile_support': None,
    'supported_vnic_types': ['*'],
}
OPENSTACK_HEAT_STACK = {
    'enable_user_pass': True,
}
IMAGE_CUSTOM_PROPERTY_TITLES = {
    "architecture": _("Architecture"),
    "kernel_id": _("Kernel ID"),
    "ramdisk_id": _("Ramdisk ID"),
    "image_state": _("Euca2ools state"),
    "project_id": _("Project ID"),
    "image_type": _("Image Type"),
}
IMAGE_RESERVED_CUSTOM_PROPERTIES = []
API_RESULT_LIMIT = 1000
API_RESULT_PAGE_SIZE = 20
SWIFT_FILE_TRANSFER_CHUNK_SIZE = 512 * 1024
INSTANCE_LOG_LENGTH = 35
DROPDOWN_MAX_ITEMS = 30
TIME_ZONE = "UTC"
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'operation': {
            'format': '%(asctime)s %(message)s'
        },
    },
    'handlers': {
        'null': {
            'level': 'DEBUG',
            'class': 'logging.NullHandler',
        },
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
        },
        'operation': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'operation',
        },
    },
    'loggers': {
        'django.db.backends': {
            'handlers': ['null'],
            'propagate': False,
        },
        'requests': {
            'handlers': ['null'],
            'propagate': False,
        },
        'horizon': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'horizon.operation_log': {
            'handlers': ['operation'],
            'level': 'INFO',
            'propagate': False,
        },
        'openstack_dashboard': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'novaclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'cinderclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'keystoneclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'glanceclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'neutronclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'heatclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'ceilometerclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'swiftclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'openstack_auth': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'nose.plugins.manager': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'django': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'iso8601': {
            'handlers': ['null'],
            'propagate': False,
        },
        'scss': {
            'handlers': ['null'],
            'propagate': False,
        },
    },
}
SECURITY_GROUP_RULES = {
    'all_tcp': {
        'name': _('All TCP'),
        'ip_protocol': 'tcp',
        'from_port': '1',
        'to_port': '65535',
    },
    'all_udp': {
        'name': _('All UDP'),
        'ip_protocol': 'udp',
        'from_port': '1',
        'to_port': '65535',
    },
    'all_icmp': {
        'name': _('All ICMP'),
        'ip_protocol': 'icmp',
        'from_port': '-1',
        'to_port': '-1',
    },
    'ssh': {
        'name': 'SSH',
        'ip_protocol': 'tcp',
        'from_port': '22',
        'to_port': '22',
    },
    'smtp': {
        'name': 'SMTP',
        'ip_protocol': 'tcp',
        'from_port': '25',
        'to_port': '25',
    },
    'dns': {
        'name': 'DNS',
        'ip_protocol': 'tcp',
        'from_port': '53',
        'to_port': '53',
    },
    'http': {
        'name': 'HTTP',
        'ip_protocol': 'tcp',
        'from_port': '80',
        'to_port': '80',
    },
    'pop3': {
        'name': 'POP3',
        'ip_protocol': 'tcp',
        'from_port': '110',
        'to_port': '110',
    },
    'imap': {
        'name': 'IMAP',
        'ip_protocol': 'tcp',
        'from_port': '143',
        'to_port': '143',
    },
    'ldap': {
        'name': 'LDAP',
        'ip_protocol': 'tcp',
        'from_port': '389',
        'to_port': '389',
    },
    'https': {
        'name': 'HTTPS',
        'ip_protocol': 'tcp',
        'from_port': '443',
        'to_port': '443',
    },
    'smtps': {
        'name': 'SMTPS',
        'ip_protocol': 'tcp',
        'from_port': '465',
        'to_port': '465',
    },
    'imaps': {
        'name': 'IMAPS',
        'ip_protocol': 'tcp',
        'from_port': '993',
        'to_port': '993',
    },
    'pop3s': {
        'name': 'POP3S',
        'ip_protocol': 'tcp',
        'from_port': '995',
        'to_port': '995',
    },
    'ms_sql': {
        'name': 'MS SQL',
        'ip_protocol': 'tcp',
        'from_port': '1433',
        'to_port': '1433',
    },
    'mysql': {
        'name': 'MYSQL',
        'ip_protocol': 'tcp',
        'from_port': '3306',
        'to_port': '3306',
    },
    'rdp': {
        'name': 'RDP',
        'ip_protocol': 'tcp',
        'from_port': '3389',
        'to_port': '3389',
    },
}
REST_API_REQUIRED_SETTINGS = ['OPENSTACK_HYPERVISOR_FEATURES',
                              'LAUNCH_INSTANCE_DEFAULTS',
                              'OPENSTACK_IMAGE_FORMATS']
ALLOWED_PRIVATE_SUBNET_CIDR = {'ipv4': [], 'ipv6': []}
COMPRESS_OFFLINE=True
EOF

##############################################################################
# Install Cinder on Controller
##############################################################################

DEBIAN_FRONTEND=noninteractive apt install -yq cinder-api cinder-scheduler

cat > cinder.sql << EOF
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'ShtajigOleackRuf';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'ShtajigOleackRuf';
EOF
mysql --user=root --password="Mw&slwbt" < cinder.sql
mysqldump --host=os-con-1.example.com --port=3306 --user=cinder --password=ShtajigOleackRuf cinder

openstack user create --domain default --password ShtajigOleackRuf cinder
openstack role add --project service --user cinder admin
openstack service create --name cinder --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack endpoint create --region RegionOne volume public http://os-con-1.example.com:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume internal http://os-con-1.example.com:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume admin http://os-con-1.example.com:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 public http://os-con-1.example.com:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://os-con-1.example.com:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://os-con-1.example.com:8776/v2/%\(tenant_id\)s

mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf.org
cat > /etc/cinder/cinder.conf << EOF
[DEFAULT]
# enabled_backends = lvm
auth_strategy = keystone
transport_url = rabbit://openstack:CebrOssImyaufsay@os-con-1.example.com
my_ip = 172.16.226.121

[BACKEND]

[BRCD_FABRIC_EXAMPLE]

[CISCO_FABRIC_EXAMPLE]

[COORDINATION]

[FC-ZONE-MANAGER]

[KEY_MANAGER]

[barbican]

[cors]

[cors.subdomain]

[database]
connection = mysql+pymysql://cinder:ShtajigOleackRuf@os-con-1.example.com/cinder

[key_manager]

[keystone_authtoken]
auth_uri = http://os-con-1.example.com:5000
auth_url = http://os-con-1.example.com:35357
region_name = RegionOne
memcached_servers = os-con-1.example.com:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = cinder
password = ShtajigOleackRuf
auth_type = password

[matchmaker_redis]

[oslo_concurrency]
lock_path = /var/lock/cinder

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[oslo_reports]

[oslo_versionedobjects]

[ssl]

[lvm]
# volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
# volume_group = pkgosvg0
# iscsi_protocol = iscsi
# iscsi_helper = tgtadm
EOF

su -s /bin/sh -c "cinder-manage db sync" cinder

service nova-api restart
service cinder-scheduler restart

##############################################################################
# Install Cinder on Host
##############################################################################

pvcreate /dev/sdb
vgcreate cinder-volumes /dev/sdb

cat > /etc/lvm/lvmlocal.conf << EOF
config {
checks = 1
abort_on_errors = 0
profile_dir = "/etc/lvm/profile"
}
devices {
dir = "/dev"
scan = [ "/dev" ]
obtain_device_list_from_udev = 1
external_device_info_source = "none"
cache_dir = "/run/lvm"
cache_file_prefix = ""
write_cache_state = 1
sysfs_scan = 1
multipath_component_detection = 1
md_component_detection = 1
fw_raid_component_detection = 0
md_chunk_alignment = 1
data_alignment_detection = 1
data_alignment = 0
data_alignment_offset_detection = 1
ignore_suspended_devices = 0
ignore_lvm_mirrors = 1
disable_after_error_count = 0
require_restorefile_with_uuid = 1
pv_min_size = 2048
issue_discards = 0
allow_changes_with_duplicate_pvs = 0
filter = [ "a/sda/", "a/sdb/", "r/.*/"]
}
allocation {
maximise_cling = 1
use_blkid_wiping = 1
wipe_signatures_when_zeroing_new_lvs = 1
mirror_logs_require_separate_pvs = 0
cache_pool_metadata_require_separate_pvs = 0
thin_pool_metadata_require_separate_pvs = 0
}
log {
verbose = 0
silent = 0
syslog = 1
overwrite = 0
level = 0
indent = 1
command_names = 0
prefix = "  "
activation = 0
debug_classes = [ "memory", "devices", "activation", "allocation", "lvmetad", "metadata", "cache", "locking", "lvmpolld", "dbus" ]
}
backup {
backup = 1
backup_dir = "/etc/lvm/backup"
archive = 1
archive_dir = "/etc/lvm/archive"
retain_min = 10
retain_days = 30
}
shell {
history_size = 100
}
global {
umask = 077
test = 0
units = "h"
si_unit_consistency = 1
suffix = 1
activation = 1
proc = "/proc"
etc = "/etc"
locking_type = 1
wait_for_locks = 1
fallback_to_clustered_locking = 1
fallback_to_local_locking = 1
locking_dir = "/run/lock/lvm"
prioritise_write_locks = 1
abort_on_internal_errors = 0
detect_internal_vg_cache_corruption = 0
metadata_read_only = 0
mirror_segtype_default = "raid1"
raid10_segtype_default = "raid10"
sparse_segtype_default = "thin"
use_lvmetad = 1
use_lvmlockd = 0
system_id_source = "none"
use_lvmpolld = 1
notify_dbus = 1
}
activation {
checks = 0
udev_sync = 1
udev_rules = 1
verify_udev_operations = 0
retry_deactivation = 1
missing_stripe_filler = "error"
use_linear_target = 1
reserved_stack = 64
reserved_memory = 8192
process_priority = -18
raid_region_size = 512
readahead = "auto"
raid_fault_policy = "warn"
mirror_image_fault_policy = "remove"
mirror_log_fault_policy = "allocate"
snapshot_autoextend_threshold = 100
snapshot_autoextend_percent = 20
thin_pool_autoextend_threshold = 100
thin_pool_autoextend_percent = 20
use_mlockall = 0
monitoring = 1
polling_interval = 15
activation_mode = "degraded"
}
dmeventd {
mirror_library = "libdevmapper-event-lvm2mirror.so"
snapshot_library = "libdevmapper-event-lvm2snapshot.so"
thin_library = "libdevmapper-event-lvm2thin.so"
}
EOF

DEBIAN_FRONTEND=noninteractive apt install -yq cinder-volume tgt

mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf.org
cat > /etc/cinder/cinder.conf << EOF
[DEFAULT]
enabled_backends = lvm
auth_strategy = keystone
transport_url = rabbit://openstack:CebrOssImyaufsay@os-con-1.example.com
my_ip = 172.16.226.121
glance_api_servers = http://os-con-1.example.com:9292

[BACKEND]

[BRCD_FABRIC_EXAMPLE]

[CISCO_FABRIC_EXAMPLE]

[COORDINATION]

[FC-ZONE-MANAGER]

[KEY_MANAGER]

[barbican]

[cors]

[cors.subdomain]

[database]
connection = mysql+pymysql://cinder:ShtajigOleackRuf@os-con-1.example.com/cinder

[key_manager]

[keystone_authtoken]
auth_uri = http://os-con-1.example.com:5000
auth_url = http://os-con-1.example.com:35357
region_name = RegionOne
memcached_servers = os-con-1.example.com:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = cinder
password = ShtajigOleackRuf
auth_type = password

[matchmaker_redis]

[oslo_concurrency]
lock_path = /var/lock/cinder

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[oslo_reports]

[oslo_versionedobjects]

[ssl]

[lvm]
# volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
# volume_group = pkgosvg0
# iscsi_protocol = iscsi
# iscsi_helper = tgtadm
EOF

service tgt restart
service cinder-volume restart

openstack volume service list

##############################################################################
# Bash completion on Controller
##############################################################################
source admin-openrc
openstack complete | sudo tee /etc/bash_completion.d/osc.bash_completion > /dev/null
source /etc/bash_completion

##############################################################################
# Create instance on Controller
##############################################################################
source admin-openrc
openstack network create  --share --external \
  --provider-physical-network provider \
  --provider-network-type flat provider
openstack subnet create --network provider \
  --allocation-pool start=172.16.20.2,end=172.16.20.253 \
  --dns-nameserver 172.16.226.20 --gateway 172.16.20.254 \
  --subnet-range 172.16.20.0/24 provider
openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano
source demo-openrc
ssh-keygen -q -N ""
openstack keypair create --public-key ~/.ssh/id_rsa.pub mykey
openstack keypair list
openstack security group rule create --proto icmp default
openstack security group rule create --proto tcp --dst-port 22 default
openstack flavor list
openstack image list
openstack network list
openstack security group list
openstack server create --flavor m1.nano --image cirros \
  --nic net-id=provider --security-group default \
  --key-name mykey provider-instance
openstack server list
openstack console url show provider-instance
