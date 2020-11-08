#!/bin/bash
openstack volume create \
  --description 'K8S master01 containers volume' \
  --source k8s_server_containers \
  --type premium \
  k8s_master01_containers

openstack volume create \
  --description 'K8S master02 containers volume' \
  --source k8s_server_containers \
  --type premium \
  k8s_master02_containers

openstack volume create \
  --description 'K8S worker01 containers volume' \
  --image k8s_server_containers \
  --size 20 \
  --type standard \
  k8s_worker01_containers

openstack volume create \
  --description 'K8S worker02 containers volume' \
  --image k8s_server_containers \
  --size 20 \
  --type standard \
  k8s_worker02_containers

openstack volume create \
  --description 'K8S worker03 containers volume' \
  --image k8s_server_containers \
  --size 20 \
  --type standard \
  k8s_worker03_containers

openstack server add volume \
  k8s_master01 \
  k8s_master01_containers

openstack server add volume \
  k8s_master02 \
  k8s_master02_containers

openstack server add volume \
  k8s_worker01 \
  k8s_worker01_containers

openstack server add volume \
  k8s_worker02 \
  k8s_worker02_containers

openstack server add volume \
  k8s_worker03 \
  k8s_worker03_containers
