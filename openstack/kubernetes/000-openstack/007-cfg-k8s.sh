if [[ ! -d $HOME/.virtualenvs ]]; then mkdir $HOME/.virtualenvs; fi
virtualenv --python=/usr/bin/python3 $HOME/.virtualenvs/openstack
source $HOME/.virtualenvs/openstack/bin/activate
pip install -U \
  pip \
  setuptools

pip install -U \
  osc-placement \
  osc-placement-tree \
  python-barbicanclient \
  python-cinderclient \
  python-designateclient \
  python-glanceclient \
  python-heatclient \
  python-keystoneclient \
  python-neutronclient \
  python-novaclient \
  python-octaviaclient \
  python-openstackclient

cat > ~/osk8s.sh <<EOF
for key in \$( set | awk '{FS="="}  /^OS_/ {print \$1}' ); do unset \$key ; done
export OS_AUTH_PLUGIN=password
export OS_AUTH_URL=https://openstack.se.lemche.net:35357/v3
export OS_CACERT=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
export OS_ENDPOINT_TYPE=internalURL
export OS_IDENTITY_API_VERSION=3
export OS_INTERFACE=internal
export OS_PASSWORD=passw0rd
export OS_PLACEMENT_API_VERSION=1.28
export OS_PROJECT_DOMAIN_NAME=Default
export OS_PROJECT_NAME=kubernetes
export OS_REGION_NAME=RegionOne
export OS_TENANT_NAME=kubernetes
export OS_USER_DOMAIN_NAME=Default
export OS_USERNAME=k8sadmin
EOF
source ~/osk8s.sh
openstack token issue

cat <<EOF | sudo tee /etc/kubernetes/cloud-config
[Global]
region=RegionOne
username=k8sadmin
password=passw0rd
auth-url=https://openstack.se.lemche.net:35357/v3
tenant-id=$(openstack project show $OS_PROJECT_NAME -f value -c id)
domain-id=default
ca-file=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem

[LoadBalancer]
subnet-id=$(openstack subnet show k8s_subnet -f value -c id)
floating-network-id=$(openstack network show routing -f value -c id)

[BlockStorage]
bs-version=v2

[Networking]
public-network-name=public
ipv6-support-disabled=false
EOF

cat <<EOF | sudo tee /etc/kubernetes/kubeadm-config.yml
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: l6nzlf.qeh5m3839hlux140
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
  kubeletExtraArgs:
    cloud-provider: external
  name: master01.k8s.se.lemche.net
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  extraArgs:
    enable-admission-plugins: NodeRestriction
    runtime-config: storage.k8s.io/v1=true
  certSANs:
  - k8s.se.lemche.net
  - 192.168.254.88
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager:
  extraArgs:
    external-cloud-volume-plugin: openstack
  extraVolumes:
  - hostPath: /etc/kubernetes/cloud-config
    mountPath: /etc/kubernetes/cloud-config
    name: cloud-config
    pathType: File
    readOnly: true
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "192.168.8.8:6443"
networking:
  dnsDomain: cluster.local
  podSubnet: 10.224.0.0/16
  serviceSubnet: 192.168.8.0/24
scheduler: {}
EOF
sudo kubeadm init --config=/etc/kubernetes/kubeadm-config.yml

if [[ -d $HOME/.kube ]]; then rm -fr $HOME/.kube; fi
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl describe no master01

kubectl create secret -n kube-system generic cloud-config --from-literal=cloud.conf="$(cat /etc/kubernetes/cloud-config)" --dry-run -o yaml | sudo tee /etc/kubernetes/cloud-config-secret.yaml
kubectl apply -f /etc/kubernetes/cloud-config-secret.yaml

kubectl apply -f https://github.com/kubernetes/cloud-provider-openstack/raw/release-1.15/cluster/addons/rbac/cloud-controller-manager-roles.yaml
kubectl apply -f https://github.com/kubernetes/cloud-provider-openstack/raw/release-1.15/cluster/addons/rbac/cloud-controller-manager-role-bindings.yaml

cat <<EOF | sudo tee /etc/kubernetes/openstack-cloud-controller-manager-ds.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cloud-controller-manager
  namespace: kube-system
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: openstack-cloud-controller-manager
  namespace: kube-system
  labels:
    k8s-app: openstack-cloud-controller-manager
spec:
  selector:
    matchLabels:
      k8s-app: openstack-cloud-controller-manager
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        k8s-app: openstack-cloud-controller-manager
    spec:
      nodeSelector:
        node-role.kubernetes.io/master: ""
      securityContext:
        runAsUser: 1001
      tolerations:
      - key: node.cloudprovider.kubernetes.io/uninitialized
        value: "true"
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      - effect: NoSchedule
        key: node.kubernetes.io/not-ready
      serviceAccountName: cloud-controller-manager
      containers:
        - name: openstack-cloud-controller-manager
          image: docker.io/k8scloudprovider/openstack-cloud-controller-manager:v1.15.0
          args:
            - /bin/openstack-cloud-controller-manager
            - --v=1
            - --cloud-config=$(CLOUD_CONFIG)
            - --cloud-provider=openstack
            - --use-service-account-credentials=true
            - --address=127.0.0.1
          volumeMounts:
            - mountPath: /etc/kubernetes/pki
              name: k8s-certs
              readOnly: true
            - mountPath: /etc/ssl/certs
              name: ca-certs
              readOnly: true
            - mountPath: /etc/config
              name: cloud-config-volume
              readOnly: true
            - mountPath: /usr/libexec/kubernetes/kubelet-plugins/volume/exec
              name: flexvolume-dir
            - mountPath: /etc/kubernetes
              name: ca-cert
              readOnly: true
          resources:
            requests:
              cpu: 200m
          env:
            - name: CLOUD_CONFIG
              value: /etc/config/cloud.conf
      hostNetwork: true
      volumes:
      - hostPath:
          path: /usr/libexec/kubernetes/kubelet-plugins/volume/exec
          type: DirectoryOrCreate
        name: flexvolume-dir
      - hostPath:
          path: /etc/kubernetes/pki
          type: DirectoryOrCreate
        name: k8s-certs
      - hostPath:
          path: /etc/ssl/certs
          type: DirectoryOrCreate
        name: ca-certs
      - name: cloud-config-volume
        secret:
          secretName: cloud-config
      - name: ca-cert
        secret:
          secretName: openstack-ca-cert
EOF
kubectl apply -f /etc/kubernetes/openstack-cloud-controller-manager-ds.yaml

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# check if token is expired
sudo kubeadm token list

# re-create token and show join command
sudo kubeadm token create --print-join-command

cat <<EOF | sudo tee /etc/kubernetes/worker-kubeadm-config.yml
apiVersion: kubeadm.k8s.io/v1beta2
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.8.7:6443
    token: h448lr.ue8vp03m2gq3i1uz
    caCertHashes: ["sha256:0786deb9cef3121391aeb4dcccd28f0acfb2c9f49bc5952fe6c7ed06da2e740a"]
kind: JoinConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: "external"
EOF
scp /etc/kubernetes/worker-kubeadm-config.yml worker01.k8s.se.lemche.net:~/kubeadm-config.yml
ssh worker01.k8s.se.lemche.net "sudo cat ~/kubeadm-config.yml"
ssh worker01.k8s.se.lemche.net "sudo kubeadm join --v=5  --config ~/kubeadm-config.yml"
