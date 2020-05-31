#!/bin/sh

echo '***'
echo '*** create kolla inventory templates'
echo '***'
cp ${VIRTUAL_ENV}/share/kolla-ansible/ansible/inventory/* /etc/kolla/

echo '***'
echo '*** deploy openstack kolla'
echo '***'
kolla-ansible -i /etc/kolla/all-in-one bootstrap-servers \
&& kolla-ansible -i /etc/kolla/all-in-one prechecks \
&& kolla-ansible -i /etc/kolla/all-in-one deploy \
&& kolla-ansible -i /etc/kolla/all-in-one post-deploy

echo '***'
echo '*** source in OS configuration'
echo '***'
. /etc/kolla/admin-openrc.sh

echo '***'
echo '*** add additional cinder volume types'
echo '***'
openstack volume type create \
  --property volume_backend_name='premium' \
  premium
openstack volume type create \
  --property volume_backend_name='standard' \
  standard

echo '***'
echo '*** In case we just want to run a test configuration'
echo '***'
${VIRTUAL_ENV}/share/kolla-ansible/init-runonce

echo '***'
echo '*** connect to OpenStack as the octavia service user'
echo '***'
cat << EOF >> $HOME/octavia-openrc
export OS_PROJECT_NAME=service
export OS_USERNAME=octavia
export OS_PASSWORD=$OCTAVIA_PASS
export OS_IMAGE_API_VERSION=2
export OS_VOLUME_API_VERSION=3
EOF

echo '***'
echo '*** create amphora image'
echo '***'
openstack image create \
  --disk-format qcow2 \
  --container-format bare \
  --tag octavia-amphora-image \
  --file $HOME/amphora-x64-haproxy.qcow2 \
  --private \
  --project service amphora-x64-haproxy

echo '***'
echo '*** create amphora flavor'
echo '***'
openstack flavor create \
  --id 200 \
  --vcpus 1 \
  --ram 1024 \
  --disk 2 \
  --private \
  "amphora"

openstack security group create \
  lb-mgmt-sec-grp
openstack security group rule create \
  --protocol icmp \
  lb-mgmt-sec-grp
openstack security group rule create \
  --protocol tcp \
  --dst-port 22 \
  lb-mgmt-sec-grp
openstack security group rule create \
  --protocol tcp \
  --dst-port 9443 \
  lb-mgmt-sec-grp
openstack security group create \
  lb-health-mgr-sec-grp
openstack security group rule create \
  --protocol udp \
  --dst-port 5555 \
  lb-health-mgr-sec-grp
