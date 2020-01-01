#!/bin/bash

sudo systemctl start \
  chrony \
  bind9 \
  mysql \
  rabbitmq-server \
  memcached \
  etcd \
  dirsrv-admin \
  dirsrv@default.service \
  pki-tomcatd \
  apache2 \
  ipvsadm \
  haproxy

sudo systemctl start \
  glance-registry \
  glance-api

sudo systemctl start \
  neutron-server \
  neutron-l3-agent \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent \
  neutron-linuxbridge-agent

sudo systemctl start \
  cinder-scheduler \
  tgt \
  cinder-volume

sudo systemctl start \
  qemu-kvm \
  nova-api \
  nova-xvpvncproxy \
  nova-console \
  nova-consoleauth \
  nova-scheduler \
  nova-conductor \
  nova-novncproxy \
  nova-compute

sudo systemctl start \
  designate-worker \
  designate-producer \
  designate-central \
  designate-api \
  designate-agent \
  designate-mdns
