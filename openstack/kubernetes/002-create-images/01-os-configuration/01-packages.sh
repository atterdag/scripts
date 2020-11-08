#!/bin/bash

echo '***'
echo '*** updating APT repositories'
echo '***'
sudo apt-get --yes update \
&& sudo apt-get --yes --upgrade dist-upgrade

echo '***'
echo '*** install required packages'
echo '***'
sudo apt-get --yes --quiet --reinstall install \
  acl \
  attr \
  ca-certificates \
  curl \
  lvm2 \
  parted \
  python3-bs4 \
  python3-lxml \
  python3-openstackclient \
  quota \
  xfsdump \
  xfsprogs
