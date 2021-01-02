#!/bin/sh

echo '***'
echo '*** create namespace for hello-kubernetes'
echo '***'
cat <<EOF | kubectl apply -f -
---
kind: Namespace
apiVersion: v1
metadata:
  name: hello-kubernetes-namespace
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
EOF

echo '***'
echo '*** install hello-kubernetes pod'
echo '***'
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Pod
metadata:
  name: hello-pod
  namespace: hello-kubernetes-namespace
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

echo '***'
echo '*** check if hello-kubernetes pod is running'
echo '***'
kubectl get pods -n hello-kubernetes-namespace
kubectl describe pods -n hello-kubernetes-namespace
kubectl exec hello-pod -n hello-kubernetes-namespace -- ps faux
kubectl exec hello-pod -n hello-kubernetes-namespace -it -- sh -l

echo '***'
echo '*** delete hello-kubernetes pod'
echo '***'
kubectl delete pods hello-pod -n hello-kubernetes-namespace

echo '***'
echo '*** create hello-kubernetes replicaset'
echo '***'
cat <<EOF | kubectl apply -f -
---
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: hello-rs
  namespace: hello-kubernetes-namespace
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

echo '***'
echo '*** check if hello-kubernetes replicaset is running'
echo '***'
kubectl get pods --show-labels -n hello-kubernetes-namespace
kubectl get rs --output=yaml -n hello-kubernetes-namespace

echo '***'
echo '*** create hello-kubernetes service'
echo '***'
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Service
metadata:
  name: hello-service
  namespace: hello-kubernetes-namespace
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

echo '***'
echo '*** check if hello-kubernetes service is running'
echo '***'
kubectl get service hello-service -n hello-kubernetes-namespace --output=yaml

echo '***'
echo '*** Use curl to connect to the ClusterIP'
echo '***'
ssh ${K8S_CONTROL_PLANE_FQDN} curl $(kubectl get service hello-service -n hello-kubernetes-namespace -o jsonpath="{.spec.clusterIP}"):8080

echo '***'
echo '*** Use curl to connect to the NodePort'
echo '***'
curl http://${K8S_CONTROL_PLANE_FQDN}:30001

echo '***'
echo '*** clean-up'
echo '***'
kubectl delete service hello-service -n hello-kubernetes-namespace
kubectl delete replicasets hello-rs -n hello-kubernetes-namespace
kubectl delete namespace hello-kubernetes-namespace

echo '***'
echo '*** Create namespace again'
echo '***'
cat <<EOF | kubectl apply -f -
---
kind: Namespace
apiVersion: v1
metadata:
  name: hello-kubernetes-namespace
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
EOF

echo '***'
echo '*** Deploy pods'
echo '***'
cat <<EOF | kubectl apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-kubernetes-deployment
  namespace: hello-kubernetes-namespace
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
        - name: hello-kubernetes-pod
          image: docker.io/ckaserer/hello-kubernetes
          ports:
            - containerPort: 8080
          resources:
            limits:
              cpu: 500m
            requests:
              cpu: 200m
EOF

echo '***'
echo '*** Create horizontal autoscaling of pods'
echo '***'
cat <<EOF | kubectl apply -f -
---
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: hello-kubernetes-autoscale
  namespace: hello-kubernetes-namespace
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hello-kubernetes-deployment
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
EOF

echo '***'
echo '*** Create a Cluster IP service'
echo '***'
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Service
metadata:
  name: hello-kubernetes-service-clusterip
  namespace: hello-kubernetes-namespace
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
spec:
  sessionAffinity: None
  type: ClusterIP
  ports:
    - name: hello-kubernetes-service-clusterip-https
      port: 443
      targetPort: 8080
      protocol: TCP
  selector:
    app: hello-kubernetes
EOF

echo '***'
echo '*** Create secret with SSL key pair for hello kubernetes HTTP proxy'
echo '***'
etcdctl --username user:$ETCD_USER_PASS get /keystores/HELLO_KUBERNETES.p12 \
| tr -d '\n' \
| base64 --decode \
> ${HELLO_KUBERNETES_FQDN}.p12

cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  tls.crt: $(openssl pkcs12 \
  -in ${HELLO_KUBERNETES_FQDN}.p12 \
  -passin pass:${HELLO_KUBERNETES_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| base64 -w0)
  tls.key: $(openssl pkcs12 \
  -in ${HELLO_KUBERNETES_FQDN}.p12 \
  -passin pass:${HELLO_KUBERNETES_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| openssl rsa 2>/dev/null \
| base64 -w0 -)
kind: Secret
metadata:
  name: hello-kubernetes-secret-certificate
  namespace: hello-kubernetes-namespace
type: kubernetes.io/tls
EOF

rm -f ${HELLO_KUBERNETES_FQDN}.p12

echo '***'
echo '*** Create a HTTP Proxy for the service'
echo '***'
cat <<EOF | kubectl apply -f -
---
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: hello-kubernetes-httpproxy
  namespace: hello-kubernetes-namespace
  labels:
    zone: test
    version: v1
    app: hello-kubernetes
spec:
  virtualhost:
    fqdn: ${HELLO_KUBERNETES_FQDN}
    tls:
      secretName: hello-kubernetes-secret-certificate
  routes:
    - services:
        - name: hello-kubernetes-service-clusterip
          port: 443
EOF

echo '***'
echo '*** Create a Load Balancer in the projectcontour namespace'
echo '***'
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Service
metadata:
  name: hello-kubernetes-service-loadbalancer
  namespace: projectcontour
  annotations:
    metallb.universe.tf/address-pool: applications
spec:
  externalTrafficPolicy: Local
  ports:
    - port: 443
      name: https
      protocol: TCP
  selector:
    app: envoy
  type: LoadBalancer
  loadBalancerIP: ${HELLO_KUBERNETES_IP_ADDRESS}
EOF
