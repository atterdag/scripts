#!/bin/sh

echo '***'
echo '*** reconfigure kolla'
echo '***'
kolla-ansible -i /etc/kolla/all-in-one reconfigure
