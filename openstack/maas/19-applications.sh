#!/bin/sh

# Create a new namespace
kubectl create namespace kube-verify

# Create a new deployment
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

# Check the resources that were created by the deployment
kubectl get all -n kube-verify

# Create a service for the deployment
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

# Examine the new service
kubectl get -n kube-verify service/kube-verify

# Use curl to connect to the ClusterIP
ssh k8smaster.se.lemche.net curl $(kubectl get -n kube-verify service/kube-verify -o jsonpath="{.spec.clusterIP}")

# Create a LoadBalancer service for the kube-verify deployment
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

# View the new kube-verify service
kubectl get service kube-verify -n kube-verify

curl $(kubectl get -n kube-verify service/kube-verify -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

# Delete namespace
kubectl delete namespace kube-verify
