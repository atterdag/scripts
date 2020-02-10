#!/bin/bash

##############################################################################
# Remove OpenStack immediate dependencies
##############################################################################
sudo apt-get --yes --quiet --purge remove \
  libapache2-mod-wsgi* \
  libvirt0 \
  memcached \
  mysql-common \
  python3-castellan \
  python3-memcache \
  python3-pymysql \
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
  /var/lib/haproxy/ \
  /var/lib/libvirt/ \
  /var/lib/openvswitch/ \
  /var/log/haproxy.log* \
  /var/log/openvswitch/ \
  /var/log/trafficserver/

for user in radvd rabbitmq; do
  if getent passwd $user; then
    sudo userdel -r $user
  fi
done
