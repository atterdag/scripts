echo '***'
echo '*** clean downloaded packages'
echo '***'
openstack server image create \
  --name k8s_server \
  --wait \
  k8s_server

openstack server remove volume \
  k8s_server \
  k8s_server_containers

openstack image create \
  --disk-format qcow2 \
  --force \
  --public \
  --volume k8s_server_containers \
  k8s_server_containers

openstack server add volume \
  k8s_server \
  k8s_server_containers
