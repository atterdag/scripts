#!/bin/sh

echo '***'
echo '*** setting up disk'
echo '***'
sudo lvcreate -L5G -n kubelet containers
sudo mkfs.xfs -f /dev/containers/kubelet
echo -e "/dev/mapper/containers-kubelet /var/lib/kubelet xfs defaults,nofail\t0\t0" | sudo tee -a /etc/fstab
sudo mkdir /var/lib/kubelet
sudo mount /var/lib/kubelet

echo '***'
echo '*** letting iptables see bridged traffic'
echo '***'
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
