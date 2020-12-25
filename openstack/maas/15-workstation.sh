echo '***'
echo '*** create and load script to import openstack configuration'
echo '***'
cat > $HOME/prepare-node.env << EOF
##############################################################################
# Getting the environment up for a node
##############################################################################
if [[ ! \$0 =~ bash ]]; then
 echo "You cannot _run_ this script, you have to *source* it."
 exit 1
fi

# Get read privileges to etcd
if [[ -z \${ETCD_USER_PASS+x} ]]; then
  echo "ETCD_USER_PASS is undefined, run the following to set it"
  echo 'echo "Fetch from user password from secret management"; read -s ETCD_USER_PASS'
  return 1
fi

export ETCDCTL_DISCOVERY_SRV="$ROOT_DNS_DOMAIN"

# Create variables with infrastructure configuration
for key in \$(etcdctl ls /variables/ | sed 's|^/variables/||'); do
    export eval \$key="\$(etcdctl get /variables/\$key)"
done

# Create variables with secrets
for secret in \$(etcdctl --username user:\$ETCD_USER_PASS ls /passwords/ | sed 's|^/passwords/||'); do
    export eval \$secret="\$(etcdctl --username user:\$ETCD_USER_PASS get /passwords/\$secret)"
done
EOF
source $HOME/prepare-node.env

echo '***'
echo '*** copy kubectl config from master01'
echo '***'
ssh-keygen -f "/home/atterdag/.ssh/known_hosts" -R "${K8S_CONTROL_PLANE_FQDN}"
scp -o StrictHostKeyChecking=no -r ${K8S_CONTROL_PLANE_FQDN}:~/.kube/config ~/.kube/${K8S_CLUSTER_NAME}.config
KUBECONFIG=~/.kube/${K8S_CLUSTER_NAME}.config:~/.kube/config kubectl config view --flatten --merge > ~/.kube/new-config
mv ~/.kube/new-config ~/.kube/config
kubectl config set-context kubernetes-admin@${K8S_CLUSTER_NAME}
kubectl get nodes

echo '***'
echo '*** install Calico Layer 3 networking solution for pod networks'
echo '***'
# curl --silent --url https://docs.projectcalico.org/manifests/calico.yaml \
# | sed -E 's|(.*)(#\s)(.*)(value:.*)("192.168.0.0/16")|\1\3\4"'${K8S_POD_NETWORK_CIDR}'"|; s|(.*)(#\s)(.*)(-\sname:\sCALICO_IPV4POOL_CIDR)|\1\3\4|;' \
# | tee calico.yaml
# kubectl apply -f calico.yaml
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo '***'
echo '*** install helm'
echo '***'
curl \
  --output - \
  https://get.helm.sh/helm-v3.4.1-linux-amd64.tar.gz \
| tar \
  --extract \
  --gzip \
  --verbose \
  --directory=/tmp \
  linux-amd64/helm \
&& sudo mv /tmp/linux-amd64/helm \
  /usr/local/bin/helm

echo '***'
echo '*** add bash completion scripts for helm, and kubectl'
echo '***'
helm completion bash | sudo tee /etc/bash_completion.d/helm
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
. /etc/bash_completion
