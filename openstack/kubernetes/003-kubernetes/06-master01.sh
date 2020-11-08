#!/bin/sh

ssh -o StrictHostKeyChecking=no -A -J debian@192.168.254.84 debian@192.168.8.8

echo '***'
echo '*** initializing master (THIS IS ALSO GOING TO TAKE A WHILE)'
echo '***'
cat <<EOF | tee kubeadm.conf
---
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: l6nzlf.qeh5m3839hlux140
  description: "default kubeadm bootstrap token"
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.8.8
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: master01.os.se.lemche.net
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
  kubeletExtraArgs:
    cloud-provider: "external"
---
apiServer:
  timeoutForControlPlane: 4m0s
  certSANs:
  - master01.se.lemche.net
  - 192.168.8.8
  - k8s.se.lemche.net
  - 192.168.254.88
  extraArgs:
    cloud-provider: "external"
    enable-admission-plugins: NodeRestriction
    runtime-config: storage.k8s.io/v1=true
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: k8sos
controllerManager:
  extraArgs:
    cloud-provider: "external"
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
  podSubnet: 10.224.0.0/16
  serviceSubnet: 192.168.8.0/24
scheduler: {}
controlPlaneEndpoint: 192.168.8.8:6443
EOF

echo '***'
echo '*** initializing master (THIS IS ALSO GOING TO TAKE A WHILE)'
echo '***'
sudo kubeadm init --config kubeadm.conf --dry-run \
&& sudo kubeadm init --config kubeadm.conf

echo '***'
echo '*** enabling user to run kubadm'
echo '***'
if [[ -d ~/.kube ]]; then rm -fr ~/.kube; fi \
&& mkdir -p $HOME/.kube \
&& sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config \
&& sudo chown $(id -u):$(id -g) $HOME/.kube/config \
&& echo "export KUBECONFIG=$HOME/.kube/config" >> .profile \
&& . .profile

echo '***'
echo '*** - allow master node to run pods'
echo '***'
kubectl taint nodes --all node-role.kubernetes.io/master-

echo '***'
echo '*** install Calico Layer 3 networking solution for pod networks'
echo '***'
curl --silent --url https://docs.projectcalico.org/manifests/calico.yaml \
| sed -E 's|(.*)(#\s)(.*)(value:.*)("192.168.0.0/16")|\1\3\4"10.224.0.0/16"|; s|(.*)(#\s)(.*)(-\sname:\sCALICO_IPV4POOL_CIDR)|\1\3\4|;' \
| tee calico.yaml
kubectl apply -f calico.yaml

# echo '***'
# echo '*** install Flannel Layer 3 networking solution for pod networks'
# echo '***'
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# echo '***'
# echo '*** install Romana Layer 3 networking solution for pod networks'
# echo '***'
# kubectl apply -f https://raw.githubusercontent.com/romana/romana/master/containerize/specs/romana-kubeadm.yml

# echo '***'
# echo '*** install Weave networking solution for pod networks'
# echo '***'
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
