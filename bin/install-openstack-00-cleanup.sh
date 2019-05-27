#!/bin/sh

##############################################################################
# Remove OpenStack, and immediate dependencies
##############################################################################
sudo apt-get --yes --purge remove \
  chrony \
  cinder* \
  etcd \
  glance* \
  keystone* \
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
  tgt
sudo apt-get --yes --purge autoremove
sudo rm -fr \
  /etc/cinder/ \
  /etc/keystone/ \
  /etc/libvirt/ \
  /etc/mysql/ \
  /etc/neutron/ \
  /etc/nova/ \
  /etc/openstack-dashboard/ \
  /etc/openvswitch/ \
  /etc/trafficserver/\
  /var/cache/trafficserver/ \
  /var/lib/libvirt/ \
  /var/lib/glance/ \
  /var/lib/nova/ \
  /var/lib/openvswitch/ \
  /var/lib/openstack/ \
  /var/log/nova/ \
  /var/log/openvswitch/ \
  /var/log/trafficserver/

for user in cinder glance keystone neutron nova radvd rabbitmq; do
  sudo userdel -r $user
done

##############################################################################
# Remove packages on all base packages
##############################################################################
sudo apt-get --yes --purge remove \
  apache2 \
  bind9 \
  bind9-doc \
  bind9utils
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
sudo apt-get install --yes python-pip
for i in $(pip list | awk '{print $1}'); do sudo -i pip uninstall -y $i; done
sudo apt-get --reinstall --yes install $(echo $(dpkg -l | awk '{print $2}' | tail -n +5 | grep ^python-) | sed 's|\n| |g')
