#!/bin/sh

echo '***'
echo '*** Install Contour with default values'
echo '***'
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

echo '***'
echo '*** Configure Contour to use specific IP address on Load Balancer'
echo '***'
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
echo '*** Check Load Balancer is using correct IP'
echo '***'
kubectl get -n projectcontour service envoy

echo '***'
echo '*** Deploy KUARD in Contour namespace to just test Contour'
echo '***'
cat <<EOF | kubectl apply -f -
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

echo '***'
echo '*** Create KUARD service infront of deployment'
echo '***'
cat <<EOF | kubectl apply -f -
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

echo '***'
echo '*** Create ingress so we can test Contour/KUARD on port 80'
echo '***'
cat <<EOF | kubectl apply -f -
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: kuard
  namespace: projectcontour
  labels:
    app: kuard
spec:
  backend:
    serviceName: kuard
    servicePort: 80
EOF

echo '***'
echo '*** Create ingress so we can test Contour/KUARD on port 80'
echo '***'
curl http://${KUARD_IP_ADDRESS}:80

echo '***'
echo '*** Create secret with SSL key pair for KUARD HTTP Proxy'
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

cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  tls.crt: $(openssl pkcs12 \
  -in ${KUARD_FQDN}.p12 \
  -passin pass:${KUARD_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| base64 -w0)
  tls.key: $(openssl pkcs12 \
  -in ${KUARD_FQDN}.p12 \
  -passin pass:${KUARD_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| openssl rsa 2>/dev/null \
| base64 -w0 -)
kind: Secret
metadata:
  name: ${KUARD_FQDN}
  namespace: projectcontour
type: kubernetes.io/tls
EOF

rm -f ${KUARD_FQDN}.p12

echo '***'
echo '*** Create HTTP Proxy that terminates SSL traffic before KUARD service'
echo '***'
cat <<EOF | kubectl apply -f -
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

echo '***'
echo '*** Check that HTTP proxy is valid'
echo '***'
kubectl get -n projectcontour httpproxies.projectcontour.io kuard

echo '***'
echo '*** Check that HTTP proxy is using the correct SSL certificate'
echo '***'
echo Q | openssl s_client -connect ${KUARD_FQDN}:443 | openssl x509 -text

echo '***'
echo '*** Check that KUARD is available over HTTPS'
echo '***'
curl https://${KUARD_FQDN}:443

echo '***'
echo '*** Check that HTTP Proxy does *NOT* allow traffic to IP address'
echo '***'
curl https://${KUARD_IP_ADDRESS}:443
