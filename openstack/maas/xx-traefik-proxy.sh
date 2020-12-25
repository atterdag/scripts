# Install traefik
helm repo add traefik https://helm.traefik.io/traefik
helm repo update

kubectl create ns traefik-v2
cat <<EOF | tee traefik-values.yaml
additionalArguments:
  - "--log.level=DEBUG"
service:
  enabled: true
  type: LoadBalancer
  # annotations:
  #   metallb.universe.tf/address-pool: system
  externalIPs:
    - 192.168.1.222
EOF
helm install --namespace=traefik-v2 --values=./traefik-values.yaml traefik traefik/traefik
# helm upgrade --namespace=traefik-v2 --values=./traefik-values.yaml traefik traefik/traefik

# Exposing the Traefik dashboard¶
cat <<EOF | tee traefik-dashboard.yaml
# dashboard.yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.se.lemche.net`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
EOF
kubectl apply -f traefik-dashboard.yaml
