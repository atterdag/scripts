#!/bin/bash

##############################################################################
# Configure, and restart cinder on Compute host
##############################################################################
# Overwrite existing /etc/cinder/cinder.conf if controller host is also compute host
sudo mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf.org
cat << EOF | sudo tee /etc/cinder/cinder.conf
[DEFAULT]
enabled_backends = premium,standard
auth_strategy = keystone
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
my_ip = ${CONTROLLER_IP_ADDRESS}
glance_api_servers = http://${CONTROLLER_FQDN}:9292

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
connection = mysql+pymysql://cinder:${CINDER_DBPASS}@${CONTROLLER_FQDN}/cinder

[key_manager]

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
username = cinder
password = $CINDER_PASS
auth_type = password

[matchmaker_redis]

[oslo_concurrency]
lock_path = /var/lib/cinder/tmp

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[oslo_reports]

[oslo_versionedobjects]

[ssl]

[premium]
iscsi_protocol = iscsi
iscsi_helper = tgtadm
lvm_type = auto
volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
volume_group = cinder-premium-vg
volume_backend_name=premium

[standard]
iscsi_protocol = iscsi
iscsi_helper = tgtadm
lvm_type = auto
volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
volume_group = cinder-standard-vg
volume_backend_name=standard
EOF
sudo chmod 0640 /etc/cinder/cinder.conf
sudo chown cinder:cinder /etc/cinder/cinder.conf

sudo systemctl restart \
  tgt \
  cinder-volume
