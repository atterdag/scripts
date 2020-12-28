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
  loadBalancerIP: ${KUARD_IP_ADDRESS}
EOF

echo '***'
echo '*** import SSL key pair for KUARD'
echo '***'
etcdctl --username user:$ETCD_USER_PASS get /keystores/KUARD.p12 \
| tr -d '\n' \
| base64 --decode \
> ${KUARD_FQDN}.p12

openssl pkcs12 \
  -in ${KUARD_FQDN}.p12 \
  -passin pass:${KUARD_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| tee ${KUARD_FQDN}.crt

openssl pkcs12 \
  -in ${KUARD_FQDN}.p12 \
  -passin pass:${KUARD_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| openssl rsa 2>/dev/null \
| tee -a ${KUARD_FQDN}.key

rm -f ${KUARD_FQDN}.p12

cat <<EOF | tee kuard-secret.yaml
apiVersion: v1
data:
  tls.crt: $(base64 -w0 ${KUARD_FQDN}.crt)
  tls.key: $(base64 -w0 ${KUARD_FQDN}.key)
kind: Secret
metadata:
  name: ${KUARD_FQDN}
  namespace: projectcontour
type: kubernetes.io/tls
EOF
kubectl apply -f kuard-secret.yaml

rm -f ${KUARD_FQDN}.crt ${KUARD_FQDN}.key

echo '***'
echo '*** Example workload'
echo '***'
cat <<EOF | tee kuard-deployment.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kuard
  name: kuard
  namespace: projectcontour
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
EOF
kubectl apply -f kuard-deployment.yaml

cat <<EOF | tee kuard-service.yaml
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: kuard
  name: kuard
  namespace: projectcontour
spec:
  ports:
  - name: kuard-https
    port: 443
    protocol: TCP
    targetPort: 8080
  - name: kuard-http
    port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: kuard
  sessionAffinity: None
  type: ClusterIP
EOF
kubectl apply -f kuard-service.yaml

cat <<EOF | tee kuard-ingress.yaml
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
kubectl apply -f kuard-ingress.yaml

cat <<EOF | tee kuard-httpproxy.yaml
---
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: kuard
  namespace: projectcontour
  labels:
    app: kuard
spec:
  virtualhost:
    fqdn: ${KUARD_FQDN}
    tls:
      secretName: ${KUARD_FQDN}
  routes:
    - services:
        - name: kuard
          port: 443

EOF
kubectl apply -f kuard-httpproxy.yaml

# Send requests to application
kubectl get -n projectcontour service envoy -o wide
