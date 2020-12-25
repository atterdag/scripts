#!/bin/sh

kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: envoy
  namespace: projectcontour
  annotations:
    metallb.universe.tf/address-pool: applications
spec:
  externalTrafficPolicy: Local
  ports:
  - port: 80
    name: http
    protocol: TCP
  - port: 443
    name: https
    protocol: TCP
  selector:
    app: envoy
  type: LoadBalancer
  loadBalancerIP: 192.168.1.224
EOF

# Example workload
cat <<EOF | tee kuard.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kuard
  name: kuard
spec:
  replicas: 3
  selector:
    matchLabels:
      app: kuard
  template:
    metadata:
      labels:
        app: kuard
    spec:
      containers:
      - image: docker.io/artpropp/kuard-aarch64:latest
        name: kuard
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: kuard
  name: kuard
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: kuard
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: kuard
  labels:
    app: kuard
spec:
  backend:
    serviceName: kuard
    servicePort: 80
EOF
kubectl apply -f kuard.yaml

# Send requests to application
kubectl get -n projectcontour service envoy -o wide
