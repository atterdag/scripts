#!/bin/sh

sudo systemctl start \
  chrony \
  bind9 \
  mysql \
  rabbitmq-server \
  memcached \
  etcd \
  dirsrv@dir.service \
  pki-tomcatd \
  apache2 \
  glance-registry \
  glance-api \
  nova-api \
  nova-consoleauth \
  nova-scheduler \
  nova-conductor \
  nova-novncproxy \
  nova-compute \
  neutron-server \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent \
  neutron-linuxbridge-agent \
  cinder-scheduler \
  tgt \
  cinder-volume \
  designate-central \
  designate-api \
  designate-agent \
  designate-mdns \
  designate-pool-manager \
  designate-sink \
  designate-zone-manager

sudo systemctl stop \
  designate-zone-manager \
  designate-sink \
  designate-pool-manager \
  designate-mdns \
  designate-agent \
  designate-api \
  designate-central \
  cinder-volume \
  tgt \
  cinder-scheduler \
  neutron-linuxbridge-agent \
  neutron-metadata-agent \
  neutron-dhcp-agent \
  neutron-linuxbridge-agent \
  neutron-server \
  nova-compute \
  nova-novncproxy \
  nova-conductor \
  nova-scheduler \
  nova-consoleauth \
  nova-api \
  glance-api \
  glance-registry \
  apache2 \
  pki-tomcatd \
  dirsrv@dir.service \
  etcd \
  memcached \
  rabbitmq-server \
  mysql \
  bind9 \
  chrony
