#!/bin/sh

echo '***'
echo '*** get the cluster CA cert hash and token'
echo '***'
source $HOME/prepare-node.env

echo '***'
echo '*** manually distribute certicates'
echo '***'
etcdctl --username user:$ETCD_USER_PASS get /keystores/K8S_CONTROL_PLANE_PKI \
| tr -d '\n' \
| base64 --decode \
| sudo tar --verbose --extract --directory=/

echo '***'
echo '*** initializing master02'
echo '***'
sudo kubeadm join ${K8S_CONTROL_PLANE_FQDN}:${K8S_CONTROL_PLANE_PORT} \
  --control-plane \
  --discovery-token-ca-cert-hash $K8S_DISCOVERY_TOKEN_CA_CERT_HASH \
  --node-name ${K8S_MASTER_TWO_HOST_NAME} \
  --token $K8S_RASP_TOKEN

echo '***'
echo '*** enabling user to run kubadm'
echo '***'
if [[ -d ~/.kube ]]; then rm -fr ~/.kube; fi \
&& mkdir -p $HOME/.kube \
&& sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config \
&& sudo chown $(id -u):$(id -g) $HOME/.kube/config \
&& echo "export KUBECONFIG=$HOME/.kube/config" >> .profile \
&& . .profile
kubectl -n kube-system get cm kubeadm-config -oyaml

echo '***'
echo '*** - allow master node to run pods'
echo '***'
# kubectl taint nodes --all node-role.kubernetes.io/master-
