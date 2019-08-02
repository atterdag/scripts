#!/bin/bash

##############################################################################
# Remove OpenStack, and immediate dependencies
##############################################################################
sudo apt-get --yes --purge remove \
  barbican-* \
  chrony \
  cinder* \
  designate-* \
  etcd \
  glance* \
  keystone* \
  krb5-* \
  libapache2-mod-wsgi* \
  libvirt0 \
  memcached \
  mysql-common \
  neutron* \
  nova* \
  python-castellan \
  python-memcache \
  python-openstack* \
  python-oslo* \
  python-pymysql \
  qemu-kvm \
  qemu-slof \
  qemu-system-common \
  qemu-system-x86 \
  qemu-utils \
  rabbitmq-server \
  radvd \
  sphinx-common \
  tgt \
  ubuntu-cloud-keyring
sudo apt-get --yes --purge autoremove
sudo rm -fr \
  /etc/barbican/ \
  /etc/cinder/ \
  /etc/designate/ \
  /etc/glance/ \
  /etc/keystone/ \
  /etc/libvirt/ \
  /etc/mysql/ \
  /etc/neutron/ \
  /etc/nova/ \
  /etc/openstack-dashboard/ \
  /etc/openvswitch/ \
  /etc/trafficserver/\
  /var/cache/trafficserver/ \
  /var/cache/glance/ \
  /var/cache/nova/ \
  /var/lib/libvirt/ \
  /var/lib/barbican/ \
  /var/lib/designate/ \
  /var/lib/glance/ \
  /var/lib/nova/ \
  /var/lib/openvswitch/ \
  /var/lib/openstack/ \
  /var/log/nova/ \
  /var/log/openvswitch/ \
  /var/log/trafficserver/

for user in barbican cinder designate glance keystone neutron nova radvd rabbitmq; do
  sudo userdel -r $user
done
