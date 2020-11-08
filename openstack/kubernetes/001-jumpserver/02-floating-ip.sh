openstack floating ip create \
  --floating-ip-address 192.168.254.84 \
  --description "Kubernetes Jump Server Node" \
  --tag kubernetes \
  routing

openstack server add floating ip \
  k8s_jumpserver01 \
  192.168.254.84

ping \
  -c 4 \
  192.168.254.84
