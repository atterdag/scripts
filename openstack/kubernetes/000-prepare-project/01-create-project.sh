#!/bin/bash

openstack project create \
  --description "Tenant used for project" \
  k8s_project

openstack user create \
  --project k8s_project \
  --password passw0rd \
  k8sadmin

openstack role add \
  --project k8s_project \
  --user k8sadmin \
  admin

cat > ~/osk8s.sh <<EOF
for key in \$( set | awk '{FS="="}  /^OS_/ {print \$1}' ); do unset \$key ; done
export OS_AUTH_PLUGIN=password
export OS_AUTH_URL=https://openstack.se.lemche.net:35357/v3
export OS_CACERT=/etc/ssl/certs/ca-certificates.crt
export OS_ENDPOINT_TYPE=internalURL
export OS_IDENTITY_API_VERSION=3
export OS_INTERFACE=internal
export OS_PASSWORD=passw0rd
export OS_PLACEMENT_API_VERSION=1.28
export OS_PROJECT_DOMAIN_NAME=Default
export OS_PROJECT_NAME=k8s_project
export OS_REGION_NAME=RegionOne
export OS_TENANT_NAME=k8s_project
export OS_USER_DOMAIN_NAME=Default
export OS_USERNAME=k8sadmin
EOF
source ~/osk8s.sh

openstack quota set \
  --cores -1 \
  --instances -1 \
  --key-pairs -1 \
  --ram -1 \
  --rbac-policies -1 \
  --server-group-members -1 \
  --server-groups -1 \
  --fixed-ips -1 \
  --floating-ips -1 \
  --networks -1 \
  --ports -1 \
  --routers -1 \
  --secgroup-rules -1 \
  --secgroups -1 \
  --subnetpools -1 \
  --subnets -1 \
  --backups -1 \
  --gigabytes -1 \
  --snapshots -1 \
  --volumes -1 \
  k8s_project

openstack quota set \
  --backup-gigabytes -1 \
  --per-volume-gigabytes -1 \
  --volume-type -1 \
  k8s_project

if [[ -f ~/.ssh/authorized_keys ]]; then
  openstack keypair create \
    --public-key ~/.ssh/authorized_keys \
    k8s_default
else
  echo | ssh-keygen -q -N ""
  openstack keypair create \
    --public-key ~/.ssh/id_rsa.pub \
    k8s_default
fi
