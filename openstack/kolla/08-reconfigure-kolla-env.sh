#!/bin/sh

echo '***'
echo '*** reconfigure kolla'
echo '***'
kolla-ansible --inventory /etc/kolla/all-in-one reconfigure
