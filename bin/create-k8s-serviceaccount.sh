# -----------------------------------------------------------------------------
# Create a service account that will get admin rights
kubectl create serviceaccount \
  docker.desktop.admin

# Create a cluster role bind that grants the service account the admin role
kubectl create clusterrolebinding \
  docker.desktop.admin \
  --serviceaccount=default:docker.desktop.admin \
  --clusterrole=admin

# Create a service account that will get edit rights
kubectl create serviceaccount \
  docker.desktop.edit

# Create a cluster role bind that grants the service account the edit role
kubectl create clusterrolebinding \
  docker.desktop.edit \
  --serviceaccount=default:docker.desktop.edit \
  --clusterrole=edit

# Create a service account that will get admin rights
kubectl create serviceaccount \
  docker.desktop.view

# Create a cluster role bind that grants the service account the view role
kubectl create clusterrolebinding \
  docker.desktop.view \
  --serviceaccount=default:docker.desktop.view \
  --clusterrole=view

# Create a ServiceAccount that can only get pods
kubectl create serviceaccount \
  docker.desktop.getpods

# Create cluster role with limited rights.
# REF: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
kubectl create clusterrole \
  docker.desktop.getpods \
  --verb=get \
  --verb=list \
  --verb=watch \
  --resource=pods

# Create cluster role binding that binds the clusterrole docker.desktop.getpods with
# the service account docker.desktop.getpods
kubectl create clusterrolebinding \
  docker.desktop.getpods \
  --serviceaccount=default:docker.desktop.getpods \
  --clusterrole=docker.desktop.getpods

# If needed we can also create a cluster-admin which is prolly too much
kubectl create serviceaccount \
  docker.desktop.clusteradmin

# Create a cluster role bind that grants the service account the admin role
kubectl create clusterrolebinding \
  docker.desktop.clusteradmin \
  --serviceaccount=default:docker.desktop.clusteradmin \
  --clusterrole=cluster-admin


# Lets start building a config file with tokens that we can use for deployment
# First create the config file with the cluster
kubectl \
  --kubeconfig=docker.desktop.config \
  config set-cluster docker.desktop \
  --server=https://kubernetes.docker.internal:6443 \
  --certificate-authority=docker.desktop.ca.crt

# Now set the credentials for the user in kube config file with the tokens for
# the serviec accounts above
kubectl \
  --kubeconfig=docker.desktop.config \
  config set-credentials docker.desktop.admin \
  --token=$(kubectl describe secrets "$(kubectl describe serviceaccount docker.desktop.admin | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')
kubectl \
  --kubeconfig=docker.desktop.config \
  config set-credentials docker.desktop.edit \
  --token=$(kubectl describe secrets "$(kubectl describe serviceaccount docker.desktop.edit | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')
kubectl \
  --kubeconfig=docker.desktop.config \
  config set-credentials docker.desktop.view \
  --token=$(kubectl describe secrets "$(kubectl describe serviceaccount docker.desktop.view | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')
kubectl \
  --kubeconfig=docker.desktop.config \
  config set-credentials docker.desktop.getpods \
  --token=$(kubectl describe secrets "$(kubectl describe serviceaccount docker.desktop.getpods | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')
kubectl \
  --kubeconfig=docker.desktop.config \
  config set-credentials docker.desktop.clusteradmin \
  --token=$(kubectl describe secrets "$(kubectl describe serviceaccount docker.desktop.clusteradmin | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')

# Now create different contexts so that you can switch between the different
# roles
kubectl \
  --kubeconfig=docker.desktop.config \
  config set-context docker.desktop.admin \
  --cluster=docker.desktop \
  --user=docker.desktop.admin
kubectl \
  --kubeconfig=docker.desktop.config \
  config set-context docker.desktop.edit \
  --cluster=docker.desktop \
  --user=docker.desktop.edit
kubectl \
  --kubeconfig=docker.desktop.config \
  config set-context docker.desktop.view \
  --cluster=docker.desktop \
  --user=docker.desktop.view
kubectl \
  --kubeconfig=docker.desktop.config \
  config set-context docker.desktop.getpods \
  --cluster=docker.desktop \
  --user=docker.desktop.getpods
kubectl \
  --kubeconfig=docker.desktop.config \
  config set-context docker.desktop.clusteradmin \
  --cluster=docker.desktop \
  --user=docker.desktop.clusteradmin

# -----------------------------------------------------------------------------
# Finally test the contexts
kubectl \
  --kubeconfig=docker.desktop.config \
  config use-context docker.desktop.getpods

# Check that you can get all pods
kubectl \
  --kubeconfig=docker.desktop.config \
  get pods \
  --all-namespaces

# Check that you can *not* get services
kubectl \
  --kubeconfig=docker.desktop.config \
  get services \
  --all-namespaces

# Switch the view user
kubectl \
  --kubeconfig=docker.desktop.config \
  config use-context docker.desktop.view

# Check that you can get services
kubectl \
  --kubeconfig=docker.desktop.config \
  get services \
  --all-namespaces

# Check that you can get *not* get secrets
kubectl \
  --kubeconfig=docker.desktop.config \
  get secrets

# Switch to admin user
kubectl \
  --kubeconfig=docker.desktop.config \
  config use-context docker.desktop.admin

# Check that you cat get secrets
kubectl \
  --kubeconfig=docker.desktop.config \
  get secrets \
  --all-namespaces

# Check that you can *not* get nodes
kubectl \
  --kubeconfig=docker.desktop.config \
  get nodes

# Switch to clusteradmin user
kubectl \
  --kubeconfig=docker.desktop.config \
  config use-context docker.desktop.clusteradmin

# Check that you cat get nodes
kubectl \
  --kubeconfig=docker.desktop.config \
  get nodes

# Switch to clusteradmin user
kubectl \
  --kubeconfig=docker.desktop.config \
  config use-context docker.desktop.clusteradmin

# Get the token for docker.desktop.clusteradmin
kubectl describe secrets "$(kubectl describe serviceaccount docker.desktop.clusteradmin | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}'

# Start kubectl proxy
kubectl \
  --kubeconfig=docker.desktop.config \
  proxy

# Open http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login and login with the token above

# Switch to admin context
kubectl config set-context docker-desktop

cat <<EOF | kubectl --kubeconfig=docker.desktop.config apply -f -
{
 "apiVersion": "v1",
 "kind": "Namespace",
 "metadata": {
   "name": "development",
   "labels": {
     "name": "development"
   }
 }
}
EOF

kubectl create serviceaccount \
  --kubeconfig=docker.desktop.config \
  dev.admin \
  --namespace=development

kubectl create clusterrolebinding \
  --kubeconfig=docker.desktop.config \
  prd.admin \
  --serviceaccount=development:docker.desktop.admin \
  --clusterrole=admin \
  --namespace=development

cat <<EOF | kubectl --kubeconfig=docker.desktop.config apply -f -
{
 "apiVersion": "v1",
 "kind": "Namespace",
 "metadata": {
   "name": "production",
   "labels": {
     "name": "production"
   }
 }
}
EOF

kubectl create serviceaccount \
  --kubeconfig=docker.desktop.config \
  prd.admin \
  --namespace=production

kubectl create clusterrolebinding \
  --kubeconfig=docker.desktop.config \
  prd.admin \
  --serviceaccount=production:docker.desktop.admin \
  --clusterrole=admin \
  --namespace=production
