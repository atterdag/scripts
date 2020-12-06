#!/#!/usr/bin/env bash

# echo '***'
# echo '*** Install metrics server'
# echo '***'
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# echo '***'
# echo '*** install heapster monitoring'
# echo '***'
# kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
# kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/grafana.yaml
# kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml

echo '***'
echo '*** install kubernetes dashboard'
echo '***'
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

echo '***'
echo '*** grant full admin privileges to Dashboards Service Account'
echo '***'
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

# kubectl create clusterrolebinding kubernetes-dashboard -n kube-system --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

echo '***'
echo '*** get the dashboard token'
echo '***'
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') | grep token: | awk '{print $2}'

echo '***'
echo '*** start proxy on your workstation'
echo '***'
kubectl proxy

echo '***'
echo '*** open http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/'
echo '*** and login with the token from above'
echo '***'

# echo '***'
# echo '*** Install helm'
# echo '***'
# curl https://helm.baltorepo.com/organization/signing.asc | sudo apt-key add -
# sudo apt-get install apt-transport-https --yes
# echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
# sudo apt-get update
# sudo apt-get install helm
#
# echo '***'
# echo '*** Install kubernetes dashboard'
# echo '***'
# # Add kubernetes-dashboard repository
# helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# # Deploy a Helm Release named "my-release" using the kubernetes-dashboard chart
# helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
kubectl -n default describe secret $(kubectl -n default get secret | grep kubernetes-dashboard-token | awk '{print $1}')
export POD_NAME=$(kubectl get pods -n kubernetes-dashboard -l "k8s-app=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
echo https://127.0.0.1:8443/
kubectl -n kubernetes-dashboard port-forward $POD_NAME 8443:8443
