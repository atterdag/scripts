#!/bin/bash

sudo systemctl stop \
  designate-mdns \
  designate-agent \
  designate-api \
  designate-central \
  designate-producer \
  designate-worker

sudo systemctl stop \
  nova-compute \
  nova-novncproxy \
  nova-conductor \
  nova-scheduler \
  nova-consoleauth \
  nova-console \
  nova-xvpvncproxy \
  nova-api \
  qemu-kvm

sudo systemctl stop \
  neutron-linuxbridge-agent \
  neutron-metadata-agent \
  neutron-dhcp-agent \
  neutron-linuxbridge-agent \
  neutron-l3-agent \
  neutron-server

sudo systemctl stop \
  cinder-volume \
  tgt \
  cinder-scheduler

sudo systemctl stop \
  glance-api \
  glance-registry

sudo systemctl stop \
  haproxy \
  ipvsadm \
  apache2 \
  pki-tomcatd \
  dirsrv-admin \
  dirsrv@default.service \
  etcd \
  memcached \
  rabbitmq-server \
  mysql \
  bind9 \
  chrony
