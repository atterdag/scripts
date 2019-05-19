#!/bin/sh

systemctl start \
  apache2 \
  glance-api \
  glance-registry \
  nova-api \
  nova-compute \
  nova-conductor \
  nova-consoleauth \
  nova-novncproxy \
  nova-scheduler \
  neutron-dhcp-agent \
  neutron-l3-agent \
  neutron-linuxbridge-agent \
  neutron-metadata-agent \
  neutron-server \
  cinder-api \
  cinder-scheduler \
  cinder-volume \
  tgt \
  designate-central \
  designate-api \
  designate-agent \
  designate-mdns \
  designate-pool-manager \
  designate-sink \
  designate-zone-manager

systemctl stop \
  apache2 \
  cinder-api \
  cinder-scheduler \
  cinder-volume \
  glance-api \
  glance-registry \
  neutron-dhcp-agent \
  neutron-l3-agent \
  neutron-linuxbridge-agent \
  neutron-metadata-agent \
  neutron-server \
  nova-api \
  nova-compute \
  nova-conductor \
  nova-consoleauth \
  nova-novncproxy \
  nova-scheduler \
  nova-spicehtml5proxy \
  nova-xenvncproxy \
  tgt \
  designate-central \
  designate-api \
  designate-agent \
  designate-mdns \
  designate-pool-manager \
  designate-sink \
  designate-zone-manager

systemctl restart \
  neutron-dhcp-agent \
  neutron-l3-agent \
  neutron-linuxbridge-agent \
  neutron-metadata-agent \
  neutron-server \
  nova-compute
