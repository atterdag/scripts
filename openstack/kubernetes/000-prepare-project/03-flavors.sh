openstack flavor create \
  --disk 5 \
  --private \
  --project k8s_project \
  --property hw:cpu_cores=1 \
  --property hw:cpu_policy=shared \
  --property hw:cpu_sockets=1 \
  --property hw:cpu_threads=1 \
  --ram 128 \
  --vcpus 1 \
  k8s_jumpserver

openstack flavor create \
  --disk 5 \
  --private \
  --project k8s_project \
  --property hw:cpu_policy=shared \
  --ram 2048 \
  --vcpus 2 \
  k8s_master

openstack flavor create \
  --disk 5 \
  --private \
  --project k8s_project \
  --property hw:cpu_policy=shared \
  --ram 4096 \
  --vcpus 4 \
  k8s_worker
