#!/bin/bash

create_logdir() {
  local _service=$1
  local _user=$2
  local _group=$3
  local _mode=$4
  echo ${_service}
  sudo rm -fr /var/log/${_service} || echo "unable to delete /var/log/${_service}"
  sudo mkdir /var/log/${_service} || echo "unable to create /var/log/${_service}"
  sudo chmod ${_mode} /var/log/${_service} || echo "unable to change permissions for /var/log/${_service}"
  sudo chown ${_user}:${_group} /var/log/${_service} || echo "unable to change ownership of /var/log/${_service}"
}

create_logdir cinder cinder adm 0750
create_logdir glance glance adm 0750
create_logdir keystone keystone keystone 0700
create_logdir nova cinder adm 0750
create_logdir placement cinder adm 0750

sudo rm -fr \
  /var/log/apache2/* \
  /var/log/chrony/* \
  /var/log/haproxy.log \
  /var/log/libvirt/* \
  /var/log/lxd/* \
  /var/log/rabbitmq/*
