#!/bin/bash

openstack security group create \
  --description "Kubernetes default rule" \
  --project k8s_project \
  k8s_default
openstack security group rule create \
  --description "Allow ingoing SSH" \
  --dst-port 22 \
  --ingress \
  --project k8s_project \
  --proto tcp \
  k8s_default
openstack security group rule create \
  --description "Allow remote IPs to ping" \
  --icmp-type 8 \
  --ingress \
  --project k8s_project \
  --proto icmp \
  k8s_default

openstack security group create \
  --description "Control-Plane Node" \
  --project k8s_project \
  k8s_control
openstack security group rule create \
  --description "Kubernetes API Server" \
  --dst-port 6443 \
  --project k8s_project \
  --proto tcp \
  k8s_control
openstack security group rule create \
  --description "etcd server client API" \
  --dst-port 2379:2380 \
  --project k8s_project \
  --proto tcp \
  k8s_control
openstack security group rule create \
  --description "Kubelet API" \
  --dst-port 10250 \
  --project k8s_project \
  --proto tcp \
  k8s_control
openstack security group rule create \
  --description "kube-scheduler" \
  --dst-port 10251 \
  --project k8s_project \
  --proto tcp \
  k8s_control
openstack security group rule create \
  --description "kube-controller-manager" \
  --dst-port 10252 \
  --project k8s_project \
  --proto tcp \
  k8s_control
openstack security group rule create \
  --description "Read-only Kubelet API" \
  --dst-port 10255 \
  --project k8s_project \
  --proto tcp \
  k8s_control

openstack security group create \
  --description "Worker Nodes" \
  --project k8s_project \
  k8s_worker
openstack security group rule create \
  --description "Kubelet AP" \
  --dst-port 10250 \
  --project k8s_project \
  --proto tcp \
  k8s_worker
openstack security group rule create \
  --description "Read-only Kubelet API" \
  --dst-port 10255 \
  --project k8s_project \
  --proto tcp \
  k8s_worker
openstack security group rule create \
  --description "NodePort Services" \
  --dst-port 30000:32767 \
  --project k8s_project \
  --proto tcp \
  k8s_worker

openstack security group create \
  --description "CNI Calico" \
  --project k8s_project \
  k8s_cni_calico
openstack security group rule create \
  --description "Calico BGP network" \
  --dst-port 179 \
  --project k8s_project \
  --proto tcp \
  k8s_cni_calico
openstack security group rule create \
  --description "Calico felix (health check)" \
  --dst-port 9099 \
  --project k8s_project \
  --proto tcp \
  k8s_cni_calico

openstack security group create \
  --description "CNI Flannel" \
  --project k8s_project \
  k8s_cni_flannel
openstack security group rule create \
  --description "Flannel" \
  --dst-port 8285 \
  --project k8s_project \
  --proto udp \
  k8s_cni_flannel
openstack security group rule create \
  --description "Flannel" \
  --dst-port 8472 \
  --project k8s_project \
  --proto udp \
  k8s_cni_flannel

openstack security group create \
  --description "CNI Weave" \
  --project k8s_project \
  k8s_cni_weave
openstack security group rule create \
  --description "Weave Net" \
  --dst-port 6781:6784 \
  --project k8s_project \
  --proto tcp \
  k8s_cni_weave
openstack security group rule create \
  --description "Weave Net" \
  --dst-port 6783:6784 \
  --project k8s_project \
  --proto udp \
  k8s_cni_weave

openstack security group create \
  --description "Allow any ingoing" \
  --project k8s_project \
  k8s_any_any
openstack security group rule create \
  --description "Allow any ingoing IPv4" \
  --ethertype IPv4 \
  --ingress \
  --project k8s_project \
  --proto any \
  --remote-ip 0.0.0.0/0 \
  k8s_any_any
openstack security group rule create \
  --description "Allow any ingoing IPv6" \
  --ethertype IPv6 \
  --ingress \
  --project k8s_project \
  --proto any \
  --remote-ip ::/0 \
  k8s_any_any
