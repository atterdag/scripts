#!/bin/sh
echo '***'
echo '*** allow kubelet traffic through firewall'
echo '***'
cat << EOF | sudo tee /etc/ufw/applications.d/kubernetes
[kubelet]
title=Kubernetes Node Agent
description=The node agent of Kubernetes, the container cluster manager
ports=10248/tcp|10250/tcp|10255/tcp

[kube-apiserver]
ports=6443/tcp

[kube-scheduler]
ports=6443/tcp

[kube-proxy]
ports=10256/tcp
EOF
for app in kubelet kube-apiserver kube-scheduler kube-proxy; do
  sudo ufw allow $app
done

for num in $(ufw status numbered | grep -E 'kubelet|kube-apiserver|kube-scheduler|kube-proxy' | perl -pe 's/\[||]//g' | awk '{print $1}'); do
  yes | sudo ufw delete $num
done
sudo rm -f /etc/ufw/applications.d/kubernetes
