#!/bin/bash

##############################################################################
# Remove packages on all base packages
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
  thin-provisioning-tools
sudo apt-get --yes --quiet --purge autoremove
sudo rm -fr \
  /etc/apache2/ \
  /etc/bind/ \
  /var/cache/bind \
  /usr/lib/x86_64-linux-gnu/dirsrv \
  /var/lib/apache2 \
  /var/log/apache2/ \
  /var/log/bind/ \
  /var/lib/ssl/

sudo systemctl stop vault
sudo systemctl disable vault
sudo systemctl daemon-reload
sudo userdel -r vault
sudo rm -fr \
  /etc/vault.d \
  /var/lib/vault \
  /etc/systemd/system/vault.service \
  /usr/local/bin/vault
