#!/bin/sh

echo '***'
echo '*** initializing master (THIS IS GOING TO TAKE A WHILE)'
echo '***'
sudo -i kubeadm init --pod-network-cidr=10.244.0.0/16 2>&1 | sudo tee /etc/kubernetes/kubeadm_init_output

echo '***'
echo '*** enabling user to run kubadm'
echo '***'
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo "export KUBECONFIG=$HOME/.kube/config" >> .profile
. .profile

echo '***'
echo '*** install Romana Layer 3 networking solution for pod networks'
echo '***'
kubectl apply -f https://raw.githubusercontent.com/romana/romana/master/containerize/specs/romana-kubeadm.yml

echo '***'
echo '*** install heapster monitoring'
echo '***'
kubectl create -f https://github.com/kubernetes/heapster/blob/master/deploy/kube-config/influxdb/influxdb.yaml
kubectl create -f https://github.com/kubernetes/heapster/blob/master/deploy/kube-config/influxdb/heapster.yaml
kubectl create -f https://github.com/kubernetes/heapster/blob/master/deploy/kube-config/influxdb/grafana.yaml

echo '***'
echo '*** install kubernetes dashboard'
echo '***'
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl proxy
