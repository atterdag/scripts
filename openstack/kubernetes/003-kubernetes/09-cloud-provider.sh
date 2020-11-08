#!/bin/sh

echo '***'
echo '*** create CA bundle with custom CAs'
echo '***'
openssl x509 -in /usr/local/share/ca-certificates/Lemche.NET_Root_CA.crt | tee ca-certificates.crt
openssl x509 -in /usr/local/share/ca-certificates/Lemche.NET_Intermediate_CA_1.crt | tee -a ca-certificates.crt

echo '***'
echo '*** create openstack connection configuration'
echo '***'
cat <<EOF | tee cloud.conf
[Global]
auth-url=https://openstack.se.lemche.net:5000/v3
ca-file=/etc/config/ca-certificates.crt
user-id=0604c04b170e46ba9b9d7c857b2c1425
username=k8sadmin
password=passw0rd
region=RegionOne
tenant-id=3314c779e76b4dabad4779245caa88d6
tenant-name=k8s_project
domain-id=default
domain-name=Default
user-domain-id=default
user-domain-name=Default
# trust-id=
# use-clouds=false
# clouds-file=
# cloud=
# Tip: You can also use Application Credential ID and Secret in place of username, password, tenant-id, and domain-id.
# application-credential-name=
# application-credential-id=
# application-credential-secret=

[Networking]
# ipv6-support-disabled=
# public-network-name
# internal-network-name

[LoadBalancer]
use-octavia=false
# floating-network-id=
# floating-subnet-id=
# lb-method=ROUND_ROBIN
# lb-provider=octavia
# lb-version=v2
# subnet-id=
# network-id=
# manage-security-groups=false
# create-monitor=false
# monitor-delay=5
# monitor-max-retries=1
# monitor-timeout=3
# internal-lb=false
# cascade-delete=true
# flavor-id=
# availability-zone=

[BlockStorage]
# bs-version=v2

[Metadata]

EOF

echo '***'
echo '*** create secret with cloud config and CA bundle'
echo '***'
cat <<EOF | tee cloud-config.yaml
kind: Secret
apiVersion: v1
metadata:
  name: cloud-config
  namespace: kube-system
data:
  cloud.conf: $(base64 cloud.conf | tr -d '\n')
  ca-certificates.crt: $(base64 ca-certificates.crt | tr -d '\n')
EOF
kubectl apply -f cloud-config.yaml

echo '***'
echo '*** install OpenStack CCM'
echo '***'
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/cluster/addons/rbac/cloud-controller-manager-roles.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/cluster/addons/rbac/cloud-controller-manager-role-bindings.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/openstack-cloud-controller-manager-ds.yaml

echo '***'
echo '*** proceed with node initalization'
echo '***'
kubectl taint nodes --all node.cloudprovider.kubernetes.io/uninitialized-

echo '***'
echo '*** install cinder CSI'
echo '***'
kubectl apply -f https://github.com/kubernetes/cloud-provider-openstack/raw/master/manifests/cinder-csi-plugin/cinder-csi-controllerplugin-rbac.yaml
kubectl apply -f https://github.com/kubernetes/cloud-provider-openstack/raw/master/manifests/cinder-csi-plugin/cinder-csi-nodeplugin-rbac.yaml
kubectl apply -f https://github.com/kubernetes/cloud-provider-openstack/raw/master/manifests/cinder-csi-plugin/cinder-csi-controllerplugin.yaml
kubectl apply -f https://github.com/kubernetes/cloud-provider-openstack/raw/master/manifests/cinder-csi-plugin/cinder-csi-nodeplugin.yaml
kubectl apply -f https://github.com/kubernetes/cloud-provider-openstack/raw/master/manifests/cinder-csi-plugin/csi-cinder-driver.yaml
