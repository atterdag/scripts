#!/bin/bash

openstack security group create \
  --description "Kubernetes default rule" \
  k8s_default
openstack security group rule create \
  --description "Allow ingoing SSH" \
  --dst-port 22 \
  --ingress \
  --proto tcp \
  k8s_default
openstack security group rule create \
  --description "Allow remote IPs to ping" \
  --icmp-type 8 \
  --ingress \
  --proto icmp \
  k8s_default

openstack security group create \
  --description "Control-Plane Node" \
  k8s_control
openstack security group rule create \
  --description "Kubernetes API Server" \
  --dst-port 6443 \
  --proto tcp \
  k8s_control
openstack security group rule create \
  --description "etcd server client API" \
  --dst-port 2379:2380 \
  --proto tcp \
  k8s_control
openstack security group rule create \
  --description "Kubelet API" \
  --dst-port 10250 \
  --proto tcp \
  k8s_control
openstack security group rule create \
  --description "kube-scheduler" \
  --dst-port 10251 \
  --proto tcp \
  k8s_control
openstack security group rule create \
  --description "kube-controller-manager" \
  --dst-port 10252 \
  --proto tcp \
  k8s_control
openstack security group rule create \
  --description "Read-only Kubelet API" \
  --dst-port 10255 \
  --proto tcp \
  k8s_control

openstack security group create \
  --description "Worker Nodes" \
  k8s_worker
openstack security group rule create \
  --description "Kubelet AP" \
  --dst-port 10250 \
  --proto tcp \
  k8s_worker
openstack security group rule create \
  --description "Read-only Kubelet API" \
  --dst-port 10255 \
  --proto tcp \
  k8s_worker
openstack security group rule create \
  --description "NodePort Services" \
  --dst-port 30000:32767 \
  --proto tcp \
  k8s_worker

openstack security group create \
  --description "CNI Calico" \
  k8s_cni_calico
openstack security group rule create \
  --description "Calico BGP network" \
  --dst-port 179 \
  --proto tcp \
  k8s_cni_calico
openstack security group rule create \
  --description "Calico felix (health check)" \
  --dst-port 9099 \
  --proto tcp \
  k8s_cni_calico

openstack security group create \
  --description "CNI Flannel" \
  k8s_cni_flannel
openstack security group rule create \
  --description "Flannel" \
  --dst-port 8285 \
  --proto udp \
  k8s_cni_flannel
openstack security group rule create \
  --description "Flannel" \
  --dst-port 8472 \
  --proto udp \
  k8s_cni_flannel

openstack security group create \
  --description "CNI Weave" \
  k8s_cni_weave
openstack security group rule create \
  --description "Weave Net" \
  --dst-port 6781:6784 \
  --proto tcp \
  k8s_cni_weave
openstack security group rule create \
  --description "Weave Net" \
  --dst-port 6783:6784 \
  --proto udp \
  k8s_cni_weave
