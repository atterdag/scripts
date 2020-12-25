#!/bin/sh

echo '***'
echo '*** enable cgroups required by k8s'
echo '***'
mv /boot/firmware/cmdline.txt /boot/firmware/cmdline.txt.orig-$(date +%Y%m%d-%H%M%S)
cat <<EOF | sudo tee /boot/firmware/cmdline.txt
net.ifnames=0 dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=LABEL=writable rootfstype=ext4 elevator=deadline  cgroup_enable=memory swapaccount=1 cgroup_memory=1 cgroup_enable=cpuset rootwait fixrtc
EOF
sudo reboot

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
sudo apt-get --yes --quiet install \
  kubelet=1.19.6-00 \
  kubeadm=1.19.6-00 \
  kubectl=1.19.6-00 \
  ipvsadm

echo '***'
echo '*** holding kubernetes packages at specific version'
echo '***'
sudo apt-mark hold kubelet kubeadm kubectl

echo '***'
echo '*** letting iptables see bridged traffic'
echo '***'
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

echo '***'
echo '*** letting iptables see bridged traffic'
echo '***'
cat <<EOF | sudo tee /etc/modules-load.d/kube-proxy-ipvs.conf
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
EOF
for module in ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack; do
  sudo modprobe $module
done

echo '***'
echo '*** add bash completion scripts for kubeadm, and kubectl'
echo '***'
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
kubeadm completion bash | sudo tee /etc/bash_completion.d/kubeadm
. /etc/bash_completion
