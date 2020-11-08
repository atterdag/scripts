#!/bin/sh

echo '***'
echo '*** adding kubernetes repository GPG key'
echo '***'
wget -q -O - https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo '***'
echo '*** adding docker kubernetes repository'
echo '***'
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

echo '***'
echo '*** updating APT repositories'
echo '***'
sudo apt-get update

echo '***'
echo '*** installing kubernetes - kubelet kubeadm kubectl'
echo '***'
sudo apt-get install -y kubeadm kubectl
