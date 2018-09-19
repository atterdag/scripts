#!/bin/sh

echo '***'
echo '*** reset previous installation of kubernetes'
echo '***'
sudo -i kubeadm reset -f
for i in $(docker image ls | grep -v IMAGE | awk '{print $3}' | grep -v IMAGE); do docker image rm $i; done
ip link delete flannel.1

echo '***'
echo '*** download kubernetes docker images (THIS IS GOING TO TAKE A WHILE)'
echo '***'
sudo -i kubeadm config images pull

echo '***'
echo '*** initializing master (THIS IS ALSO GOING TO TAKE A WHILE)'
echo '***'
sudo -i kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.1.40 2>&1 | sudo tee /etc/kubernetes/kubeadm_init_output

echo '***'
echo '*** enabling user to run kubadm'
echo '***'
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo "export KUBECONFIG=$HOME/.kube/config" >> .profile
. .profile

echo '***'
echo '*** install Flannel Layer 3 networking solution for pod networks'
echo '***'
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo '***'
echo '*** install Romana Layer 3 networking solution for pod networks'
echo '***'
kubectl apply -f https://raw.githubusercontent.com/romana/romana/master/containerize/specs/romana-kubeadm.yml

echo '***'
echo '*** install Weave networking solution for pod networks'
echo '***'
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo '***'
echo '*** install heapster monitoring'
echo '***'
kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/grafana.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml

echo '***'
echo '*** install kubernetes dashboard'
echo '***'
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl proxy
