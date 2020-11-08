openstack port create \
  --fixed-ip ip-address=192.168.8.3 \
  --network k8s_network \
  --project k8s_project \
  --security-group k8s_default \
  k8s_server
