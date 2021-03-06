#!/bin/bash

##############################################################################
# Remove OpenStack core packages
##############################################################################
sudo rm -f /var/lib/dpkg/info/glance-common.postrm

sudo apt-get --yes --quiet --purge remove \
  barbican-* \
  cinder* \
  designate-* \
  glance* \
  keystone* \
  neutron* \
  nova* \
  placement* \
  python3-openstack* \
  python3-oslo* \
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
  $OS_CONFIGURATION_DIRECTORY-dashboard/ \
  /var/lib/placement/ \
  /var/log/apache2/cinder*.log* \
  /var/log/apache2/keystone*.log* \
  /var/log/apache2/nova_placement*.log* \
  /var/log/barbican/ \
  /var/log/cinder/ \
  /var/log/designate/ \
  /var/log/glance/ \
  /var/log/keystone/ \
  /var/log/neutron/ \
  /var/log/nova/ \
  /var/log/placement/

for user in barbican cinder designate glance keystone neutron nova placement; do
  if getent passwd $user; then
    sudo userdel -r $user
  fi
done

sudo add-apt-repository --remove --yes --update cloud-archive:train
sudo rm -f /etc/apt/sources.list.d/cloudarchive-train.list.*
