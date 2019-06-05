#!/bin/sh

##############################################################################
# Install Cinder on Controller host
##############################################################################

sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet cinder-api cinder-scheduler

cat << EOF | sudo tee /var/lib/openstack/cinder.sql
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$CINDER_DBPASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$CINDER_DBPASS';
EOF
sudo chmod 0600 /var/lib/openstack/cinder.sql
sudo cat /var/lib/openstack/cinder.sql | sudo mysql --host=localhost --user=root
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=cinder --password=$CINDER_DBPASS cinder


openstack user create \
  --domain default \
  --password $CINDER_PASS \
  cinder
openstack role add \
  --project service \
  --user cinder \
  admin

openstack service create \
  --name cinder \
  --description 'OpenStack Block Storage' \
  volume
openstack service create \
  --name cinderv2 \
  --description 'OpenStack Block Storage' \
  volumev2
openstack service create \
  --name cinderv3 \
  --description 'OpenStack Block Storage' \
  volumev3

openstack endpoint create \
  --region RegionOne \
  volume public http://${CONTROLLER_FQDN}:8776/v1/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volume internal http://${CONTROLLER_FQDN}:8776/v1/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volume admin http://${CONTROLLER_FQDN}:8776/v1/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 public http://${CONTROLLER_FQDN}:8776/v2/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 internal http://${CONTROLLER_FQDN}:8776/v2/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 admin http://${CONTROLLER_FQDN}:8776/v2/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev3 public http://${CONTROLLER_FQDN}:8776/v3/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev3 internal http://${CONTROLLER_FQDN}:8776/v3/%\(project_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev3 admin http://${CONTROLLER_FQDN}:8776/v3/%\(project_id\)s

sudo usermod -a -G ssl-cert cinder

sudo mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf.org
cat << EOF | sudo tee /etc/cinder/cinder.conf
[DEFAULT]
auth_strategy = keystone
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
my_ip = ${CONTROLLER_IP_ADDRESS}

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
cafile = /etc/ssl/certs/${SSL_CA_NAME}.pem
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

[lvm]

EOF
sudo chmod 0660 /etc/cinder/cinder.conf
sudo chown cinder:cinder /etc/cinder/cinder.conf

sudo su -s /bin/sh -c "cinder-manage db sync" cinder

sudo systemctl restart \
  nova-api \
  cinder-scheduler

##############################################################################
# Install Cinder on Compute host
##############################################################################

sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet cinder-volume tgt lvm2 thin-provisioning-tools

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
cafile = /etc/ssl/certs/${SSL_CA_NAME}.pem
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

##############################################################################
# Create premium (SDD) storage on Compute host
##############################################################################

# Example if you are reusing an existing disk
sudo parted /dev/${LVM_PREMIUM_PV_DEVICE} mkpart primary $(sudo parted /dev/${LVM_PREMIUM_PV_DEVICE} unit s p free | grep "Free Space" | awk '{print $1}' | tail -n 1) 100%
sudo parted --script /dev/${LVM_PREMIUM_PV_DEVICE} set 2 lvm on
sudo pvcreate --yes /dev/${LVM_PREMIUM_PV_DEVICE}2
sudo vgcreate cinder-volumes /dev/${LVM_PREMIUM_PV_DEVICE}2
sudo vgcreate cinder-premium-vg /dev/${LVM_PREMIUM_PV_DEVICE}2

# Example if you have a dedicated disk
sudo parted --script /dev/${LVM_PREMIUM_PV_DEVICE} mklabel gpt
sudo parted --script /dev/${LVM_PREMIUM_PV_DEVICE} mkpart primary 0GB 100%
sudo parted --script /dev/${LVM_PREMIUM_PV_DEVICE} set 1 lvm on
sudo pvcreate --yes /dev/${LVM_PREMIUM_PV_DEVICE}1
sudo vgcreate cinder-premium-vg /dev/${LVM_PREMIUM_PV_DEVICE}1

##############################################################################
# Create standard (HDD) storage on Compute host
##############################################################################

sudo parted --script /dev/${LVM_STANDARD_PV_DEVICE} mklabel gpt
sudo parted --script /dev/${LVM_STANDARD_PV_DEVICE} mkpart primary 0GB 100%
sudo parted --script /dev/${LVM_STANDARD_PV_DEVICE} set 1 lvm on
sudo pvcreate --yes /dev/${LVM_STANDARD_PV_DEVICE}1
sudo vgcreate cinder-standard-vg /dev/${LVM_STANDARD_PV_DEVICE}1

##############################################################################
# Configure, and restart cinder on Compute host
##############################################################################

sudo systemctl restart \
  tgt \
  cinder-volume

openstack volume service list

openstack volume type create \
  --property volume_backend_name='premium' \
  premium

openstack volume type create \
  --property volume_backend_name='standard' \
  standard

##############################################################################
# Include cinder commands in bash completion on Controller host
##############################################################################
openstack complete | sudo tee /etc/bash_completion.d/osc.bash_completion > /dev/null
source /etc/bash_completion
