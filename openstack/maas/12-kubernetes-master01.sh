#!/bin/sh

echo '***'
echo '*** set etcd admin password so we can write to etcd'
echo '***'
if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read -s ETCD_ADMIN_PASS; fi

echo '***'
echo '*** generate k8s token and upload it to etcd'
echo '***'
K8S_RASP_TOKEN=$(sudo kubeadm token generate)
export ETCDCTL_DISCOVERY_SRV=$(hostname -d)
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/K8S_RASP_TOKEN $K8S_RASP_TOKEN

echo '***'
echo '*** create control plane vIP manifest'
echo '***'
if [[ ! -d /etc/kube-vip ]]; then
  sudo mkdir -p /etc/kube-vip
fi
cat <<EOF | sudo tee /etc/kube-vip/config.yaml
localPeer:
  id: ${K8S_MASTER_ONE_HOST_NAME}
  address: ${K8S_MASTER_ONE_IP_ADDRESS}
  port: 10000
remotePeers:
- id: ${K8S_MASTER_TWO_HOST_NAME}
  address: ${K8S_MASTER_TWO_IP_ADDRESS}
  port: 10000

vip: ${K8S_CONTROL_PLANE_IP_ADDRESS}
gratuitousARP: true
singleNode: false
startAsLeader: true
interface: eth0
loadBalancers:
- name: API Server Load Balancer
  type: tcp
  port: ${K8S_CONTROL_PLANE_PORT}
  bindToVip: false
  backends:
  - port: ${K8S_MASTER_ONE_API_PORT}
    address: ${K8S_MASTER_ONE_FQDN}
  - port: ${K8S_MASTER_TWO_API_PORT}
    address: ${K8S_MASTER_TWO_FQDN}
EOF

if [[ ! -d /etc/kubernetes/manifests ]]; then
  sudo mkdir -p /etc/kubernetes/manifests
fi
docker run \
  -it \
  --rm plndr/kube-vip:0.1.1 \
  /kube-vip \
  sample manifest \
| sed "s|plndr/kube-vip:'|plndr/kube-vip:0.1.1'|" \
| sudo tee /etc/kubernetes/manifests/kube-vip.yaml

echo '***'
echo '*** initializing master (THIS IS ALSO GOING TO TAKE A WHILE)'
echo '***'
cat <<EOF | tee kubeadm.conf
---
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: ${K8S_RASP_TOKEN}
  description: "default kubeadm bootstrap token"
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: ${K8S_MASTER_ONE_IP_ADDRESS}
  bindPort: ${K8S_MASTER_ONE_API_PORT}
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: ${K8S_MASTER_ONE_HOST_NAME}
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
  certSANs:
  - kubernetes
  - kubernetes.default
  - kubernetes.default.svc
  - kubernetes.default.svc.cluster.local
  - $(echo $K8S_SERVICE_NETWORK_CIDR | sed -E "s|^(.*)\.(.*)\.(.*)\.(.*)|\1.\2.\3.1|")
  - ${K8S_MASTER_ONE_HOST_NAME}
  - ${K8S_MASTER_ONE_FQDN}
  - ${K8S_MASTER_ONE_IP_ADDRESS}
  - ${K8S_CONTROL_PLANE_FQDN}
  - ${K8S_CONTROL_PLANE_IP_ADDRESS}
  extraArgs:
    enable-admission-plugins: NodeRestriction
    runtime-config: storage.k8s.io/v1=true
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: ${K8S_CLUSTER_NAME}
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: stable
networking:
  dnsDomain: cluster.local
  podSubnet: ${K8S_POD_NETWORK_CIDR}
  serviceSubnet: ${K8S_SERVICE_NETWORK_CIDR}
scheduler: {}
controlPlaneEndpoint: ${K8S_CONTROL_PLANE_FQDN}:${K8S_CONTROL_PLANE_PORT}
# ---
# apiVersion: kubeproxy.config.k8s.io/v1alpha1
# kind: KubeProxyConfiguration
# mode: ipvs
EOF

echo '***'
echo '*** initializing master (THIS IS ALSO GOING TO TAKE A WHILE)'
echo '***'
sudo kubeadm init --config kubeadm.conf --dry-run \
&& sudo kubeadm init --config kubeadm.conf \
&& sudo kubeadm init phase upload-certs --upload-certs

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
echo '*** get the cluster CA cert hash'
echo '***'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/K8S_DISCOVERY_TOKEN_CA_CERT_HASH "sha256:$(sudo cat /etc/kubernetes/pki/ca.crt | openssl x509 -pubkey | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')"

echo '***'
echo '*** manually distribute certicates'
echo '***'
sudo tar --create \
  /etc/kubernetes/pki/ca.crt \
  /etc/kubernetes/pki/ca.key \
  /etc/kubernetes/pki/sa.key \
  /etc/kubernetes/pki/sa.pub \
  /etc/kubernetes/pki/front-proxy-ca.crt \
  /etc/kubernetes/pki/front-proxy-ca.key \
  /etc/kubernetes/pki/etcd/ca.crt \
  /etc/kubernetes/pki/etcd/ca.key \
| base64 \
| etcdctl --username admin:"$ETCD_ADMIN_PASS" set /keystores/K8S_CONTROL_PLANE_PKI
