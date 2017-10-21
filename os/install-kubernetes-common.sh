#!/bin/sh

echo '***'
echo '*** setting up disk'
echo '***'
#  btrfs is not supported by kubernetes yet
sudo lvcreate -L5G -n kubelet containers
sudo mkfs.xfs -f /dev/containers/kubelet
echo -e "/dev/mapper/containers-kubelet /var/lib/kubelet xfs defaults\t0\t0" | sudo tee -a /etc/fstab
sudo mkdir /var/lib/kubelet
sudo mount /var/lib/kubelet

echo '***'
echo '*** configure forwarding proxy configuration to shell'
echo '***'
PRIMARY_IP=$(host -t A -4 k8smaster-1 | awk '{print $4}')
cat << EOF | sudo tee /etc/profile.d/proxyenv.sh
proxy_host="cache.example.com"
proxy_port="3128"

http_proxy="http://\${proxy_host}:\${proxy_port}";
https_proxy="https://\${proxy_host}:\${proxy_port}";
ftp_proxy="ftp://\${proxy_host}:\${proxy_port}";
no_proxy=localhost,127.0.0.1,LocalAddress,example.com,example.lan,$PRIMARY_IP
export http_proxy https_proxy ftp_proxy no_proxy;
EOF
. /etc/profile.d/proxyenv.sh

echo '***'
echo '*** adding forwarding proxy configuration to docker daemon'
echo '***'
if [ ! -d /etc/systemd/system/docker.service.d ]; then sudo mkdir -p /etc/systemd/system/docker.service.d; fi
cat << EOF | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${http_proxy}"
Environment="HTTPS_PROXY=${https_proxy}"
Environment="FTP_PROXY=${ftp_proxy}"
Environment="NO_PROXY=${no_proxy}"
EOF
sudo systemctl daemon-reload
systemctl show --property=Environment docker

echo '***'
echo '*** disabling swap'
echo '***'
sudo swapoff -a
perl -pe 's/.*swap.*sw.*\n//' < /etc/fstab | sudo tee /etc/fstab
sudo lvremove --force --force system/swap

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

echo '***'
echo '*** add bash completion scripts for kubeadm, and kubectl'
echo '***'
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
kubeadm completion bash | sudo tee /etc/bash_completion.d/kubeadm
. /etc/bash_completion

echo '***'
echo '*** disable firewall'
echo '***'
sudo ufw disable
