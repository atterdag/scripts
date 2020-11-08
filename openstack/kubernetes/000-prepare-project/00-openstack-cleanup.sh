#!/bin/bash

openstack floating ip delete 192.168.254.84
openstack floating ip delete 192.168.254.88

for server in $(openstack server list --project k8s_project -f value -c ID); do
  openstack server delete --wait $server
done

for flavor in k8s_master k8s_worker k8s_jumpserver; do
  openstack flavor delete ${flavor}
done

for volume in $(openstack volume list --project k8s_project -f value -c ID); do
  openstack volume delete --force $volume
done

for image in k8s_server k8s_server_containers; do
  openstack image delete $image
done

for group in $(openstack security group list --project k8s_project -f value -c ID); do
  for rule in $(openstack security group rule list $group  -f value -c ID); do
    openstack security group rule delete ${rule}
  done
  openstack security group delete $group
done

openstack router remove subnet k8s_router k8s_subnet
openstack router delete k8s_router

for port in $(openstack port list --project k8s_project -f value -c ID); do
  openstack port delete $port
done

openstack subnet delete k8s_subnet
openstack network delete k8s_network
openstack keypair delete k8s_default

source /etc/kolla/admin-openrc.sh
openstack project delete k8s_project
openstack user delete k8sadmin
