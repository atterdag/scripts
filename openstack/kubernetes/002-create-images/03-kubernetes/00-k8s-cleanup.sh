#!/bin/sh

echo '***'
echo '*** reset previous installation of kubernetes'
echo '***'
sudo -i kubeadm reset -f
for i in $(docker image ls | grep -v IMAGE | awk '{print $3}' | grep -v IMAGE); do docker image rm $i; done
sudo ip link delete flannel.1

echo '***'
echo '*** removing old versions'
echo '***'
sudo systemctl stop \
  kubelet \
  containerd
docker container rm --force $(docker container ls -q -a)
sudo systemctl stop docker
sudo apt-get remove \
  --yes \
  --purge \
  --allow-change-held-packages \
  kubelet \
  kubeadm \
  kubectl \
  kubernetes-cni \
  lxc-common \
  lxcfs \
  lxd-client
sudo apt-get autoremove \
  --yes \
  --purge
for mount in $(mount | grep /var/lib/kubelet | awk '{print $3}' | tac); do
  sudo umount $mount
done
sudo rm -fr /var/lib/kubelet/* \
            /etc/kubernetes/ \
            /var/lib/etcd \
            /etc/cni/net.d \
            /var/log/pods \
            /var/log/containers \
            /usr/libexec/kubernetes \
            /var/lib/dockershim
sudo lvremove --force --force containers/kubelet
perl -pe 's/.*\/var\/lib\/kubelet.*\n//' < /etc/fstab | sudo tee /etc/fstab
