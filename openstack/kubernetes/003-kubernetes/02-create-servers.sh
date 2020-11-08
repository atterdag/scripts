#!/bin/bash

openstack server create \
  --flavor k8s_master \
  --image k8s_server \
  --key-name k8s_default \
  --nic port-id=k8s_master01 \
  --wait \
  k8s_master01

openstack server create \
  --flavor k8s_master \
  --image k8s_server \
  --key-name k8s_default \
  --nic port-id=k8s_master02 \
  --wait \
  k8s_master02

openstack server create \
  --flavor k8s_worker \
  --image k8s_server \
  --key-name k8s_default \
  --nic port-id=k8s_worker01 \
  --wait \
  k8s_worker01

openstack server create \
  --flavor k8s_worker \
  --image k8s_server \
  --key-name k8s_default \
  --nic port-id=k8s_worker02 \
  --wait \
  k8s_worker02

openstack server create \
  --flavor k8s_worker \
  --image k8s_server \
  --key-name k8s_default \
  --nic port-id=k8s_worker03 \
  --wait \
  k8s_worker03
