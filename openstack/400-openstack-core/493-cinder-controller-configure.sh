#!/bin/bash

##############################################################################
# Configure Cinder on Controller host
##############################################################################
sudo crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
sudo crudini --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
sudo crudini --set /etc/cinder/cinder.conf DEFAULT my_ip ${CONTROLLER_IP_ADDRESS}
# sudo crudini --set /etc/cinder/cinder.conf DEFAULT backup_driver cinder.backup.drivers.swift
# sudo crudini --set /etc/cinder/cinder.conf DEFAULT backup_swift_url SWIFT_URL
sudo crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:${CINDER_DBPASS}@${CONTROLLER_FQDN}/cinder
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri https://${CONTROLLER_FQDN}:5000
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url https://${CONTROLLER_FQDN}:5000
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken certfile /etc/ssl/certs/${CONTROLLER_FQDN}.crt
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken keyfile /etc/ssl/private/${CONTROLLER_FQDN}.key
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken cafile /etc/ssl/certs/ca-certificates.crt
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken region_name RegionOne
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers ${CONTROLLER_FQDN}:11211
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name Default
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name Default
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken password $CINDER_PASS
sudo crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
sudo crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

sudo chmod 0660 \
  /etc/cinder/cinder.conf
sudo chown cinder:cinder \
  /etc/cinder/cinder.conf

sudo usermod -a -G ssl-cert cinder

sudo su -s /bin/sh -c "cinder-manage db sync" cinder

sudo systemctl restart \
  apache2 \
  nova-api \
  cinder-scheduler
