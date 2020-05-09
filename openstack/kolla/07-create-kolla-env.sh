#!/bin/sh

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
# ${VIRTUAL_ENV}/share/kolla-ansible/init-runonce
