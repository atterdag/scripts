#!/bin/sh

echo '***'
echo '*** install hello-kubernetes pod'
echo '***'
cat > hello-kubernetes-ns.yml << EOF
kind: Namespace
apiVersion: v1
metadata:
  name: hello-kubernetes
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
EOF
kubectl apply -f hello-kubernetes-ns.yml

echo '***'
echo '*** install hello-kubernetes pod'
echo '***'
cat > hello-kubernetes-pod.yml << EOF
---
apiVersion: v1
kind: Pod
metadata:
  name: hello-pod
  namespace: hello-kubernetes
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
spec:
  containers:
  - name: hello-ctr
    image: ckaserer/hello-kubernetes
    ports:
    - containerPort: 8080
EOF
kubectl apply -f hello-kubernetes-pod.yml

echo '***'
echo '*** check if hello-kubernetes pod is running'
echo '***'
kubectl get pods -n hello-kubernetes
kubectl describe pods -n hello-kubernetes
kubectl exec hello-kubernetes -n hello-kubernetes -- ps faux
kubectl exec hello-kubernetes -n hello-kubernetes -it -- sh -l

echo '***'
echo '*** delete hello-kubernetes pod'
echo '***'
kubectl delete pods hello-pod -n hello-kubernetes

echo '***'
echo '*** create hello-kubernetes replicaset'
echo '***'
cat > hello-kubernetes-rs.yml << EOF
---
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: hello-rs
  namespace: hello-kubernetes
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-kubernetes
  template:
    metadata:
      labels:
        zone: test
        version: v1
        app: hello-kubernetes
    spec:
      containers:
      - name: hello-ctr
        image: ckaserer/hello-kubernetes
        ports:
        - containerPort: 8080
EOF
kubectl apply -f hello-kubernetes-rs.yml

echo '***'
echo '*** check if hello-kubernetes replicaset is running'
echo '***'
kubectl get pods --show-labels -n hello-kubernetes
kubectl get rs --output=yaml -n hello-kubernetes

echo '***'
echo '*** create hello-kubernetes service'
echo '***'
cat > hello-kubernetes-svc.yml << EOF
---
apiVersion: v1
kind: Service
metadata:
  name: hello-service
  namespace: hello-kubernetes
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
spec:
  type: NodePort
  ports:
  - port: 8080
    nodePort: 30001
    targetPort: 8080
    protocol: TCP
  selector:
    app: hello-kubernetes
EOF
kubectl apply -f hello-kubernetes-svc.yml

echo '***'
echo '*** check if hello-kubernetes service is running'
echo '***'
kubectl get service hello-service -n hello-kubernetes --output=yaml

echo '***'
echo '*** Use curl to connect to the ClusterIP'
echo '***'
ssh k8smaster.se.lemche.net curl $(kubectl get service hello-service -n hello-kubernetes -o jsonpath="{.spec.clusterIP}"):8080

echo '***'
echo '*** Use curl to connect to the NodePort'
echo '***'
curl http://k8smaster.se.lemche.net:30001

echo '***'
echo '*** clean-up'
echo '***'
kubectl delete service hello-service -n hello-kubernetes
kubectl delete replicasets hello-rs -n hello-kubernetes
kubectl delete namespace hello-kubernetes

#kubectl autoscale deployment --max=15 --min=3 --cpu-percent=50 hello-kubernetes

echo '***'
echo '*** create hello-kubernetes deployment'
echo '***'
cat > hello-kubernetes-deploy.yml << EOF
---
kind: Namespace
apiVersion: v1
metadata:
  name: hello-kubernetes
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deploy
  namespace: hello-kubernetes
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
spec:
  replicas: 10
  selector:
    matchLabels:
      app: hello-kubernetes
  minReadySeconds: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: hello-kubernetes
        zone: test
        version: v1
    spec:
      containers:
      - name: hello-pod
        image: ckaserer/hello-kubernetes
        ports:
        - containerPort: 8080
---
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: hello-autoscale
  namespace: hello-kubernetes
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
spec:
  scaleTargetRef:
    apiVersion: extensions/v1beta1
    kind: Deployment
    name: hello-deploy
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 75
---
apiVersion: v1
data:
  tls.crt: $(base64 -w0 hello-kubernetes.se.lemche.net.crt)
  tls.key: $(base64 -w0 hello-kubernetes.se.lemche.net.key)
kind: Secret
metadata:
  name: hello-kubernetes
  namespace: hello-kubernetes
type: Opaque
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: hello-kubernetes
  namespace: hello-kubernetes
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
spec:
  rules:
  - host: hello-kubernetes.se.lemche.net
    http:
      paths:
      - path: /hello
        tls:
        - secretName: hello-kubernetes
        backend:
          serviceName: hello-service
          servicePort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: hello-service
  namespace: hello-kubernetes
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
  annotations:
    metallb.universe.tf/address-pool: system
spec:
  type: LoadBalancer
  loadBalancerIP: 192.168.1.221
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
  selector:
    app: hello-kubernetes
EOF
kubectl apply -f hello-kubernetes-deploy.yml --dry-run=client \
&& kubectl apply -f hello-kubernetes-deploy.yml

echo '***'
echo '*** delete hello-kubernetes deployment'
echo '***'
kubectl delete -f hello-kubernetes-deploy.yml

echo '***'
echo '*** Setup Ingress controller'
echo '***'
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/baremetal/deploy.yaml
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml

cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  tls.crt: $(base64 -w0 hello-kubernetes.se.lemche.net.crt)
  tls.key: $(base64 -w0 hello-kubernetes.se.lemche.net.key)
kind: Secret
metadata:
  name: sslcerts
  namespace: default
type: Opaque
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hello-kubernetes
  namespace: hello-kubernetes
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
spec:
  rules:
  - host: k8sworker02.se.lemche.net
    http:
      paths:
      - path: /hello
        tls:
        - secretName: sslcerts
        backend:
          serviceName: hello-service
          servicePort: 8080
EOF
