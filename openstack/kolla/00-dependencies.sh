#!/bin/sh

echo '***'
echo '*** updating APT repositories'
echo '***'
sudo apt-get update

echo '***'
echo '*** install required packages'
echo '***'
sudo apt-get --yes --quiet install \
  apt-transport-https \
  bash-completion \
  ca-certificates \
  gcc \
  git \
  gnupg2 \
  libffi-dev \
  libselinux1-dev \
  libssl-dev \
  python-dev \
  python-selinux \
  python-setuptools \
  python3-bs4 \
  python3-dev \
  python3-lxml \
  python3-pip \
  python3-virtualenv \
  software-properties-common \
  sshpass \
  ssl-cert \
  virtualenvwrapper \
  wget
