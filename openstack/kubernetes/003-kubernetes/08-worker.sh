#!/bin/sh

echo '***'
echo '*** get the cluster CA cert hash'
echo '***'
export DISCOVERY_TOKEN_CA_CERT_HASH=$(ssh -o StrictHostKeyChecking=no master01 sudo cat /etc/kubernetes/pki/ca.crt | openssl x509 -pubkey | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')

echo '***'
echo '*** join worker node'
echo '***'
cat <<EOF | tee kubeadm-config.yml
apiVersion: kubeadm.k8s.io/v1beta2
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.8.8:6443
    token: l6nzlf.qeh5m3839hlux140
    caCertHashes: ["sha256:${DISCOVERY_TOKEN_CA_CERT_HASH}"]
  timeout: 5m0s
kind: JoinConfiguration
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: $(hostname -f)
  taints: null
  kubeletExtraArgs:
    cloud-provider: "external"
EOF
sudo kubeadm join --config kubeadm-config.yml
