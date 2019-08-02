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
  haproxy \
  glance-registry \
  glance-api \
  qemu-kvm \
  nova-api \
  nova-xvpvncproxy \
  nova-console \
  nova-consoleauth \
  nova-scheduler \
  nova-conductor \
  nova-novncproxy \
  nova-compute \
  neutron-server \
  neutron-l3-agent \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent \
  neutron-linuxbridge-agent \
  cinder-scheduler \
  tgt \
  cinder-volume \
  designate-worker \
  designate-producer \
  designate-central \
  designate-api \
  designate-agent \
  designate-mdns
