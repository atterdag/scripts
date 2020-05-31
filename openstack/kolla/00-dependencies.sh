#!/bin/sh

echo '***'
echo '*** updating APT repositories'
echo '***'
sudo apt-get update

echo '***'
echo '*** install required packages'
echo '***'
sudo apt-get --yes --quiet --reinstall install \
  apt-transport-https \
  bash-completion \
  ca-certificates \
  curl \
  gcc \
  git \
  gnupg2 \
  jq \
  kpartx \
  libffi-dev \
  libselinux1-dev \
  libssl-dev \
  python-dev \
  python-pip \
  python-selinux \
  python-setuptools \
  python3-bs4 \
  python3-dev \
  python3-lxml \
  python3-pip \
  python3-virtualenv \
  qemu-utils \
  software-properties-common \
  sshpass \
  ssl-cert \
  thin-provisioning-tools \
  uuid-runtime \
  virtualenvwrapper \
  wget
