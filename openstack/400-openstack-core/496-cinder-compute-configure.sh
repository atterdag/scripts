#!/bin/bash

##############################################################################
# Configure, and restart cinder on Compute host
##############################################################################
# Overwrite existing /etc/cinder/cinder.conf if controller host is also compute host
sudo crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends "premium,standard"
sudo crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
sudo crudini --set /etc/cinder/cinder.conf DEFAULT transport_url "rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}"
sudo crudini --set /etc/cinder/cinder.conf DEFAULT my_ip ${CONTROLLER_IP_ADDRESS}
sudo crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers "http://${CONTROLLER_FQDN}:9292"
sudo crudini --set /etc/cinder/cinder.conf database connection "mysql+pymysql://cinder:${CINDER_DBPASS}@${CONTROLLER_FQDN}/cinder"
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url "https://${CONTROLLER_FQDN}:5000"
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken certfile /etc/ssl/certs/${CONTROLLER_FQDN}.crt
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken keyfile /etc/ssl/private/${CONTROLLER_FQDN}.key
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken cafile /etc/ssl/certs/ca-certificates.crt
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken region_name RegionOne
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers "${CONTROLLER_FQDN}:11211"
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name Default
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name Default
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken password $CINDER_PASS
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
sudo crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp
sudo crudini --set /etc/cinder/cinder.conf premium iscsi_protocol iscsi
sudo crudini --set /etc/cinder/cinder.conf premium iscsi_helper tgtadm
sudo crudini --set /etc/cinder/cinder.conf premium lvm_type auto
sudo crudini --set /etc/cinder/cinder.conf premium volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
sudo crudini --set /etc/cinder/cinder.conf premium volume_group cinder-premium-vg
sudo crudini --set /etc/cinder/cinder.conf premium volume_backend_name premium
sudo crudini --set /etc/cinder/cinder.conf standard iscsi_protocol iscsi
sudo crudini --set /etc/cinder/cinder.conf standard iscsi_helper tgtadm
sudo crudini --set /etc/cinder/cinder.conf standard lvm_type auto
sudo crudini --set /etc/cinder/cinder.conf standard volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
sudo crudini --set /etc/cinder/cinder.conf standard volume_group cinder-standard-vg
sudo crudini --set /etc/cinder/cinder.conf standard volume_backend_name standard

sudo chmod 0640 \
  /etc/cinder/cinder.conf
sudo chown cinder:cinder \
  /etc/cinder/cinder.conf

sudo systemctl restart \
  tgt \
  cinder-volume
