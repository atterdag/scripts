#!/bin/sh

echo '***'
echo '*** get the cluster CA cert hash and token'
echo '***'
source $HOME/prepare-node.env

echo '***'
echo '*** join worker node'
echo '***'
sudo kubeadm join ${K8S_CONTROL_PLANE_FQDN}:${K8S_CONTROL_PLANE_PORT} \
  --discovery-token-ca-cert-hash $K8S_DISCOVERY_TOKEN_CA_CERT_HASH \
  --node-name $(hostname -s) \
  --token $K8S_RASP_TOKEN
