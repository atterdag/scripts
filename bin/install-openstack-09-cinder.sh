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
mysql --user=root --password="${ROOT_DBPASS}" < /var/lib/openstack/cinder.sql
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
openstack endpoint create \
  --region RegionOne \
  volume public http://${CONTROLLER_FQDN}:8776/v1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  volume internal http://${CONTROLLER_FQDN}:8776/v1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  volume admin http://${CONTROLLER_FQDN}:8776/v1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 public http://${CONTROLLER_FQDN}:8776/v2/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 internal http://${CONTROLLER_FQDN}:8776/v2/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 admin http://${CONTROLLER_FQDN}:8776/v2/%\(tenant_id\)s

usermod -a -G ssl-cert cinder

mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf.org
cat > /etc/cinder/cinder.conf << EOF
[DEFAULT]
# enabled_backends = lvm
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
username = cinder
password = $CINDER_PASS
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
chmod 0660 /etc/cinder/cinder.conf
chown cinder:cinder /etc/cinder/cinder.conf

su -s /bin/sh -c "cinder-manage db sync" cinder

systemctl restart \
  nova-api
  cinder-scheduler

##############################################################################
# Install Cinder on Compute host
##############################################################################

sudo parted /dev/${LVM_PV_DEVICE} mkpart primary $(sudo parted /dev/${LVM_PV_DEVICE} unit s p free | grep "Free Space" | awk '{print $1}' | tail -n 1) 100%

pvcreate /dev/${LVM_PV_DEVICE}1
vgcreate cinder-volumes /dev/${LVM_PV_DEVICE}1

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
filter = [ "a/sda/", "a/${LVM_PV_DEVICE}/", "r/.*/"]
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

DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet cinder-volume tgt

# Don't overwrite if controller host is also the compute host
mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf.org
cat > /etc/cinder/cinder.conf << EOF
[DEFAULT]
enabled_backends = lvm
volume_group = cinder-volumes

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
username = cinder
password = $CINDER_PASS
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
chmod 0640 /etc/cinder/cinder.conf
chown cinder:cinder /etc/cinder/cinder.conf

systemctl restart \
  tgt \
  cinder-volume

openstack volume service list
