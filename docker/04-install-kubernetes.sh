#!/bin/sh

PRIMARY_IP=$(host -t A -4 $(hostname -f) | awk '{print $4}')

export http_proxy=http://cache.example.com:3128/
export https_proxy=https://cache.example.com:3128/
export ftp_proxy=ftp://cache.example.com:3128/
export no_proxy=localhost,127.0.0.1,LocalAddress,example.com,example.lan,$PRIMARY_IP

echo '***'
echo '*** adding removing old versions'
echo '***'
service kubelet stop
killall kube-controller-manager
apt-get -y remove --purge kubelet kubeadm kubectl lxc-common lxcfs lxd-client
apt-get -y autoremove --purge
rm -fr /var/lib/kubelet/ \
       /etc/kubernetes/ \
       /var/lib/etcd \
       /etc/cni/net.d \
       /var/log/pods \
       /var/log/containers \
       /usr/libexec/kubernetes \
       /var/lib/dockershim
       

echo '***'
echo '*** adding kubernetes repository GPG key'
echo '***'
wget -q -O - https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

echo '***'
echo '*** adding docker kubernetes repository'
echo '***'
cat > /etc/apt/sources.list.d/kubernetes.list << EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

echo '***'
echo '*** updating APT repositories'
echo '***'
apt-get update

echo '***'
echo '*** installing kubernetes - kubelet kubeadm kubectl'
echo '***'
apt-get install -y kubelet kubeadm kubectl

echo '***'
echo '*** disabling swap'
echo '***'
swapoff -a

echo '***'
echo '*** initializing master'
echo '***'
kubeadm init
