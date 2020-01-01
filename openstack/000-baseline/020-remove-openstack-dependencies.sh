#!/bin/bash

##############################################################################
# Remove OpenStack, and immediate dependencies
##############################################################################
sudo apt-get --yes --quiet --purge remove \
  chrony \
  etcd \
  krb5-* \
  libapache2-mod-wsgi* \
  libvirt0 \
  memcached \
  mysql-common \
  python-castellan \
  python-memcache \
  python-pymysql \
  rabbitmq-server \
  radvd \
  sphinx-common \
  tgt \
  ubuntu-cloud-keyring
sudo apt-get --yes --quiet --purge autoremove
sudo rm -fr \
  /etc/libvirt/ \
  /etc/mysql/ \
  /etc/openvswitch/ \
  /etc/trafficserver/\
  /var/cache/trafficserver/ \
  /var/lib/libvirt/ \
  /var/lib/openvswitch/ \
  /var/log/openvswitch/ \
  /var/log/trafficserver/

for user in radvd rabbitmq; do
  sudo userdel -r $user
done
