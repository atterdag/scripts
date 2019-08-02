#!/bin/bash

##############################################################################
# Configure Nova on Compute host
##############################################################################
# Overwrite existing /etc/nova/nova.conf if controller host is also compute host
sudo mv /etc/nova/nova.conf /etc/nova/nova.conf.org
cat << EOF | sudo tee /etc/nova/nova.conf
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
remove_unused_base_images = True
image_cache_manager_interval = 10
remove_unused_original_minimum_age_seconds = 10
remove_unused_resized_minimum_age_seconds = 10

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
cafile = /etc/ssl/certs/ca-certificates.crt
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
cafile = /etc/ssl/certs/ca-certificates.crt
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
sudo chmod 0640 /etc/nova/nova.conf
sudo chown nova:nova /etc/nova/nova.conf

sudo modprobe nbd
cat << EOF | sudo tee /etc/modules-load.d/nbd.conf
nbd
EOF

sudo usermod -a -G ssl-cert nova

# On compute node restart compute
sudo systemctl restart \
  nova-compute
