#!/bin/bash

for service in cinder glance keystone neutron nova placement; do
  echo ${service}
  sudo rm -fr /var/log/${service} || echo "unable to delete /var/log/${service}"
  sudo mkdir /var/log/${service} || echo "unable to create /var/log/${service}"
  sudo chmod 0750 /var/log/${service} || echo "unable to change permissions for /var/log/${service}"
  sudo chown $service:adm /var/log/${service} || echo "unable to change ownership of /var/log/${service}"
done

sudo rm -fr \
  /var/log/apache2/* \
  /var/log/chrony/* \
  /var/log/haproxy.log \
  /var/log/libvirt/* \
  /var/log/lxd/* \
  /var/log/rabbitmq/*
