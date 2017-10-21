#!/bin/sh

echo '***'
echo '*** removing old versions'
echo '***'
sudo systemctl stop kubelet
docker container rm --force $(docker container ls -q -a)
sudo systemctl stop docker
sudo apt-get -y remove --purge kubelet kubeadm kubectl kubernetes-cni lxc-common lxcfs lxd-client
sudo apt-get -y autoremove --purge
sudo rm -fr /var/lib/kubelet/* \
            /etc/kubernetes/ \
            /var/lib/etcd \
            /etc/cni/net.d \
            /var/log/pods \
            /var/log/containers \
            /usr/libexec/kubernetes \
            /var/lib/dockershim
for mount in $(mount | grep /var/lib/kubelet | awk '{print $3}' | tac); do
  sudo umount $mount
done
sudo lvremove --force --force containers/kubelet
perl -pe 's/.*\/var\/lib\/kubelet.*\n//' < /etc/fstab | sudo tee /etc/fstab
sudo reboot
