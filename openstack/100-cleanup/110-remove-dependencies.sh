#!/bin/sh

##############################################################################
# Remove packages on all base packages
##############################################################################
sudo apt-get --yes --purge remove \
  389-ds \
  apache2 \
  arptables \
  bind9 \
  bind9-doc \
  bind9utils \
  binutils \
  build-essential \
  cpp \
  cpp-7 \
  gcc-7-base \
  genisoimage \
  krb5-locales \
  libisl19 \
  libmpc3 \
  libsasl2-modules-gssapi-mit \
  make \
  python \
  ssl-cert \
  thin-provisioning-tools
sudo apt-get --yes --purge autoremove
sudo rm -fr \
  /etc/apache2/ \
  /etc/bind/ \
  /etc/ssl/ \
  /var/cache/bind \
  /usr/lib/x86_64-linux-gnu/dirsrv \
  /var/lib/apache2 \
  /var/log/apache2/ \
  /var/log/bind/ \
  /var/lib/ssl/
