#!/bin/bash

##############################################################################
# Remove packages on all additional dependencies
##############################################################################
sudo apt-get --yes --quiet --purge remove \
  389-ds \
  apache2 \
  arptables \
  bind9 \
  bind9-doc \
  bind9utils \
  binutils \
  build-essential \
  chrony \
  cpp \
  cpp-7 \
  etcd \
  gcc-7-base \
  genisoimage \
  krb5-* \
  krb5-locales \
  libisl19 \
  libmpc3 \
  libsasl2-modules-gssapi-mit \
  make \
  python \
  thin-provisioning-tools
sudo apt-get --yes --quiet --purge autoremove
sudo rm -fr \
  /etc/apache2/ \
  /etc/bind/ \
  /usr/lib/x86_64-linux-gnu/dirsrv \
  /var/cache/bind \
  /var/lib/apache2 \
  /var/lib/chrony/ \
  /var/lib/etcd/ \
  /var/lib/krb5kdc/ \
  /var/log/apache2/ \
  /var/log/chrony/ \
  /var/log/bind/
