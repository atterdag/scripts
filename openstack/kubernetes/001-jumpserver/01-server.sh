openstack server create \
  --flavor k8s_jumpserver \
  --image debian-9-openstack-amd64 \
  --key-name k8s_default \
  --nic port-id=k8s_jumpserver01 \
  --wait \
  k8s_jumpserver01
