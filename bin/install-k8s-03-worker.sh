#!/bin/sh

echo '***'
echo '*** clearing /var/lib/kubelet/'
echo '***'
sudo rm -fr /var/lib/kubelet/*

echo '***'
echo '*** find kubeadm join command on master with the following command, and then'
echo '*** run it on this node as root'
echo '***'
sudo $(ssh -q k8smaster-1 "grep 'kubeadm join --token' /etc/kubernetes/kubeadm_init_output")

echo '***'
echo '*** - or allow master node to run pods'
echo '***'
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl taint node  node-role.kubernetes.io/master:NoSchedule-
