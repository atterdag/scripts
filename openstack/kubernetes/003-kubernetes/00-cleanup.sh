openstack floating ip delete 192.168.254.88

openstack server delete k8s_worker03
openstack server delete k8s_worker02
openstack server delete k8s_worker01
openstack server delete k8s_master02
openstack server delete k8s_master01

openstack volume delete k8s_worker03_containers
openstack volume delete k8s_worker02_containers
openstack volume delete k8s_worker01_containers
openstack volume delete k8s_master02_containers
openstack volume delete k8s_master01_containers
