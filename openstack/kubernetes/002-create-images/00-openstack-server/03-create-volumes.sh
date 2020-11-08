#!/bin/bash
openstack volume create \
  --description 'K8S server containers volume' \
  --size 20 \
  --type premium \
  k8s_server_containers

openstack server add volume \
  k8s_server \
  k8s_server_containers
