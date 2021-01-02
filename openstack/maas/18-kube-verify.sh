#!/bin/sh

echo '***'
echo '*** Create a new namespace for kube-verify'
echo '***'
kubectl create namespace kube-verify

echo '***'
echo '*** Create a new deployment'
echo '***'
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kube-verify
  namespace: kube-verify
  labels:
    app: kube-verify
spec:
  replicas: 3
  selector:
    matchLabels:
      app: kube-verify
  template:
    metadata:
      labels:
        app: kube-verify
    spec:
      containers:
      - name: nginx
        image: quay.io/clcollins/kube-verify:01
        ports:
        - containerPort: 8080
EOF

echo '***'
echo '*** Check the resources that were created by the deployment'
echo '***'
kubectl get all -n kube-verify

echo '***'
echo '*** Create a service for the deployment'
echo '***'
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: kube-verify
  namespace: kube-verify
spec:
  selector:
    app: kube-verify
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
EOF

echo '***'
echo '*** Examine the new service'
echo '***'
kubectl get -n kube-verify service/kube-verify

echo '***'
echo '*** Use curl to connect to the ClusterIP'
echo '***'
ssh k8smaster.se.lemche.net curl $(kubectl get -n kube-verify service/kube-verify -o jsonpath="{.spec.clusterIP}")

echo '***'
echo '*** Create a LoadBalancer service for the kube-verify deployment'
echo '***'
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: kube-verify
  namespace: kube-verify
spec:
  selector:
    app: kube-verify
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
EOF

echo '***'
echo '*** View the new kube-verify service'
echo '***'
kubectl get service kube-verify -n kube-verify

echo '***'
echo '*** Use curl to connect to the LoadBalancer'
echo '***'
curl $(kubectl get -n kube-verify service/kube-verify -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo '***'
echo '*** Delete namespace'
echo '***'
kubectl delete namespace kube-verify
