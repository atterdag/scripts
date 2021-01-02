#!/bin/bash

echo '***'
echo '*** Change Kubernetes to enforce strict ARP'
echo '***'
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

echo '***'
echo '*** Install MetalLB'
echo '***'
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml

echo '***'
echo '*** Create PSK for MetalLB members on first install only'
echo '***'
if ! kubectl get secret -n metallb-system memberlist  --output=name > /dev/null; then
  kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
fi

echo '***'
echo '*** Create the config map to set address ranges'
echo '***'
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: system
      protocol: layer2
      addresses:
      - ${K8S_LOADBALANCER_ADDRESS_RANGE_SYSTEM}
    - name: applications
      protocol: layer2
      addresses:
      - ${K8S_LOADBALANCER_ADDRESS_RANGE_APPLICATIONS}
EOF
