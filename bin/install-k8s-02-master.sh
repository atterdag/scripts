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
echo '*** allow OS swap to be enable'
echo '***'
cat << EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--fail-swap-on=false
EOF

echo '***'
echo '*** initializing master (THIS IS ALSO GOING TO TAKE A WHILE)'
echo '***'
sudo -i kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$(hostname -i) --ignore-preflight-errors=swap 2>&1 | sudo tee /etc/kubernetes/kubeadm_init_output

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
echo '*** Install metrics server'
echo '***'
git clone https://github.com/kubernetes-incubator/metrics-server.git
kubectl create -f metrics-server/deploy/1.8+/

echo '***'
echo '*** install heapster monitoring'
echo '***'
kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/grafana.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml

echo '***'
echo '*** install kubernetes dashboard'
echo '***'
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

echo '***'
echo '*** grant full admin privileges to Dashboards Service Account'
echo '***'
cat > dashboard-admin.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
EOF
kubectl create -f dashboard-admin.yaml

echo '***'
echo '*** get the dashboard token'
echo '***'
kubectl -n kube-system describe secrets kubernetes-dashboard-token

echo '***'
echo '*** start proxy on your workstation'
echo '***'
kubectl proxy

echo '***'
echo '*** open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login'
echo '*** and login with the token from above'
echo '***'
