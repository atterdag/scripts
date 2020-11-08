openstack server create \
  --flavor k8s_master \
  --image debian-9-openstack-amd64 \
  --key-name k8s_default \
  --nic port-id=k8s_server \
  --wait \
  k8s_server
