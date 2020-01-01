#!/bin/bash

##############################################################################
# Remove OpenStack core packages
##############################################################################
sudo apt-get --yes --quiet --purge remove \
  barbican-* \
  cinder* \
  designate-* \
  glance* \
  keystone* \
  neutron* \
  nova* \
  python-openstack* \
  python-oslo* \
  qemu-kvm \
  qemu-slof \
  qemu-system-common \
  qemu-system-x86 \
  qemu-utils
sudo apt-get --yes --quiet --purge autoremove
sudo rm -fr \
  /etc/barbican/ \
  /etc/cinder/ \
  /etc/designate/ \
  /etc/glance/ \
  /etc/keystone/ \
  /etc/neutron/ \
  /etc/nova/ \
  /etc/openstack-dashboard/ \
  /var/cache/glance/ \
  /var/cache/nova/ \
  /var/lib/barbican/ \
  /var/lib/designate/ \
  /var/lib/glance/ \
  /var/lib/nova/ \
  /var/log/nova/

for user in barbican cinder designate glance keystone neutron nova; do
  sudo userdel -r $user
done
