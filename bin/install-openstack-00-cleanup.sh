#!/bin/sh

##############################################################################
# Remove OpenStack, and immediate dependencies
##############################################################################
sudo apt-get --yes --purge remove \
  chrony \
  etcd \
  libapache2-mod-wsgi \
  libvirt0 \
  memcached \
  mysql-common \
  open-iscsi \
  python-castellan \
  python-memcache \
  python-openstack* \
  python-pymysql \
  qemu-kvm \
  qemu-slof \
  qemu-system-common \
  qemu-system-x86 \
  qemu-utils \
  rabbitmq-server \
  sphinx-common \
  tgt
sudo apt-get --yes --purge autoremove
sudo rm -fr \
  /etc/cinder/ \
  /etc/libvirt/ \
  /etc/mysql/ \
  /etc/neutron/ \
  /etc/nova/ \
  /etc/openstack-dashboard/ \
  /etc/openvswitch/ \
  /etc/trafficserver/\
  /var/cache/trafficserver/ \
  /var/lib/libvirt/ \
  /var/lib/nova/ \
  /var/lib/openvswitch/ \
  /var/lib/openstack/ \
  /var/log/nova/ \
  /var/log/openvswitch/ \
  /var/log/trafficserver/

##############################################################################
# Remove packages on all base packages
##############################################################################
sudo apt-get --yes --purge remove \
  apache2 \
  bind9 \
  bind9-doc \
  bind9utils \
  openssl
sudo apt-get --yes --purge autoremove
sudo rm -fr \
  /etc/apache2/ \
  /etc/bind/ \
  /etc/ssl/ \
  /var/log/apache2/ \
  /var/log/bind/ \
  /var/lib/ssl/

##############################################################################
# Remove all Python modules installed by pip, and reset to package versions
##############################################################################

for i in $(pip list | awk '{print $1}'); do sudo pip uninstall -y $i; done
sudo apt-get --reinstall install $(echo $(dpkg -l | awk '{print $2}' | tail -n +5 | grep ^python-) | sed 's|\n| |g')
