echo '***'
echo '*** copy kubectl config from master01'
echo '***'
ssh-keygen -f "/home/atterdag/.ssh/known_hosts" -R "k8s.se.lemche.net"
scp -o StrictHostKeyChecking=no -r debian@k8s.se.lemche.net:~/.kube/config ~/.kube/k8sos.config
KUBECONFIG=~/.kube/k8sos.config:~/.kube/config kubectl config view --flatten --merge > ~/.kube/new-config
sed 's|192.168.8.8|192.168.254.88|' ~/.kube/new-config > ~/.kube/config
kubectl config set-context kubernetes-admin@k8sos
kubectl get nodes
