#!/bin/bash

openstack flavor create \
  --disk 20 \
  --public \
  --ram 4096 \
  --vcpus 2 \
  --property hw:cpu_policy=shared \
  k8s_master

openstack flavor create \
  --disk 20 \
  --public \
  --ram 8192 \
  --vcpus 4 \
  --property hw:cpu_policy=shared \
  k8s_worker

openstack port create \
  --fixed-ip ip-address=192.168.8.8 \
  --network k8s_network \
  --security-group k8s_default \
  --security-group k8s_control \
  --security-group k8s_cni_flannel \
  master01

openstack port create \
  --fixed-ip ip-address=192.168.8.11 \
  --network k8s_network \
  --security-group k8s_default \
  --security-group k8s_worker \
  --security-group k8s_cni_flannel \
  worker01

openstack port create \
  --fixed-ip ip-address=192.168.8.12 \
  --network k8s_network \
  --security-group k8s_default \
  --security-group k8s_worker \
  --security-group k8s_cni_flannel \
  worker02

openstack server create \
  --flavor k8s_master \
  --image CentOS-7-x86_64-GenericCloud \
  --key-name k8s_default \
  --nic port-id=master01 \
  --wait \
  master01

openstack server create \
  --flavor k8s_worker \
  --image CentOS-7-x86_64-GenericCloud \
  --key-name k8s_default \
  --nic port-id=worker01 \
  --wait \
  worker01

openstack server create \
  --flavor k8s_worker \
  --image CentOS-7-x86_64-GenericCloud \
  --key-name k8s_default \
  --nic port-id=worker02 \
  --wait \
  worker02

openstack floating ip create \
  --floating-ip-address 192.168.254.88 \
  --description "Kubernetes Master Node" \
  --tag kubernetes \
  routing

openstack server add floating ip \
  master01 \
  192.168.254.88

ping \
  -c 4 \
  192.168.254.88

openstack volume create \
  --description 'K8S master data volume' \
  --size 20 \
  --type premium \
  master01_data

openstack server add volume \
  master01 \
  master01_data

openstack volume create \
  --description 'K8S worker01 data volume' \
  --size 20 \
  --type standard \
  worker01_data

openstack server add volume \
  worker01 \
  worker01_data

openstack volume create \
  --description 'K8S worker02 data volume' \
  --size 20 \
  --type standard \
  worker02_data

openstack server add volume \
  worker02 \
  worker02_data
