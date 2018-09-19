#!/bin/sh

echo '***'
echo '*** install hello-world pod'
echo '***'
cat > hello-world-pod.yml << EOF
---
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
  labels:
    zone: test
    version: v1
spec:
  containers:
  - name: hello-ctr
    image: nigelpoulton/k8sbook:latest
    ports:
    - containerPort: 8080
EOF
kubectl create -f hello-world-pod.yml

echo '***'
echo '*** check if hello-world pod is running'
echo '***'
kubectl get pods
kubectl describe pods
kubectl exec hello-pod -it sh
kubectl exec hello-pod ps faux

echo '***'
echo '*** delete hello-world pod'
echo '***'
kubectl delete pods hello-world

echo '***'
echo '*** create hello-world replicaset'
echo '***'
cat > hello-world-rs.yml << EOF
---
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: hello-world
spec:
  replicas: 10
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-ctr
        image: nigelpoulton/k8sbook:latest
        ports:
        - containerPort: 8080
EOF
kubectl create -f hello-world-rs.yml

echo '***'
echo '*** check if hello-world replicaset is running'
echo '***'
kubectl get pods --show-labels
kubectl get rs --output=yaml

echo '***'
echo '*** create hello-world service'
echo '***'
cat > hello-world-svc.yml << EOF
---
apiVersion: v1
kind: Service
metadata:
  name: hello-world
  labels:
    app: hello-world
spec:
  type: NodePort
  ports:
  - port: 8080
    nodePort: 30001
    protocol: TCP
  selector:
    app: hello-world
EOF
kubectl create -f hello-world-svc.yml

echo '***'
echo '*** check if hello-world service is running'
echo '***'
kubectl get service hello-world --output=yaml

echo '***'
echo '*** open http://<master>:30001'
echo '***'

echo '***'
echo '*** clean-up'
echo '***'
kubectl delete service hello-world
kubectl delete replicasets hello-world

echo '***'
echo '*** create hello-world deployment'
echo '***'
cat > hello-world-deploy.yml << EOF
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: hello-world
spec:
  replicas: 10
  selector:
    matchLabels:
      app: hello-world
  minReadySeconds: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-ctr
        image: nigelpoulton/k8sbook:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: hello-world
  labels:
    app: hello-world
spec:
  type: NodePort
  ports:
  - port: 8080
    nodePort: 30001
    protocol: TCP
  selector:
    app: hello-world
EOF
kubectl create -f hello-world-deploy.yml
