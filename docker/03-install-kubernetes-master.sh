#!/bin/sh

PRIMARY_IP=$(host -t A -4 $(hostname -f) | awk '{print $4}')

export http_proxy=http://cache.example.com:3128/
export https_proxy=https://cache.example.com:3128/
export ftp_proxy=ftp://cache.example.com:3128/
export no_proxy=localhost,127.0.0.1,LocalAddress,example.com,example.lan,$PRIMARY_IP

echo '***'
echo '*** adding removing old versions'
echo '***'
sudo service kubelet stop
sudo killall kube-controller-manager
sudo apt-get -y remove --purge kubelet kubeadm kubectl lxc-common lxcfs lxd-client
sudo apt-get -y autoremove --purge
sudo rm -fr /var/lib/kubelet/ \
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
sudo apt-get install -y kubelet kubeadm kubectl

echo '***'
echo '*** disabling swap'
echo '***'
sudo swapoff -a

echo '***'
echo '*** initializing master (THIS IS GOING TO TAKE A WHILE)'
echo '***'
sudo kubeadm init 2>&1 | tee kubeadm_init.output

echo '***'
echo '*** enabling user to run kubadm'
echo '***'
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
