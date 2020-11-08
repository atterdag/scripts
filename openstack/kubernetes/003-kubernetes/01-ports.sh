openstack port create \
  --fixed-ip ip-address=192.168.8.8 \
  --network k8s_network \
  --project k8s_project \
  --security-group k8s_cni_calico \
  --security-group k8s_control \
  --security-group k8s_default \
  k8s_master01

openstack port create \
  --fixed-ip ip-address=192.168.8.9 \
  --network k8s_network \
  --project k8s_project \
  --security-group k8s_cni_calico \
  --security-group k8s_control \
  --security-group k8s_default \
  k8s_master02

openstack port create \
  --fixed-ip ip-address=192.168.8.11 \
  --network k8s_network \
  --project k8s_project \
  --security-group k8s_cni_calico \
  --security-group k8s_default \
  --security-group k8s_worker \
  k8s_worker01

openstack port create \
  --fixed-ip ip-address=192.168.8.12 \
  --network k8s_network \
  --project k8s_project \
  --security-group k8s_cni_calico \
  --security-group k8s_default \
  --security-group k8s_worker \
  k8s_worker02

openstack port create \
  --fixed-ip ip-address=192.168.8.13 \
  --network k8s_network \
  --project k8s_project \
  --security-group k8s_cni_calico \
  --security-group k8s_default \
  --security-group k8s_worker \
  k8s_worker03
