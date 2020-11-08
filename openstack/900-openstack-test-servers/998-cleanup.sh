#!/bin/bash

openstack floating ip list
openstack floating ip delete routing
openstack floating ip delete e976a714-fecc-4d92-b93c-1ba6c828e857
openstack router remove subnet testfloat testfloat
openstack router delete testfloat
openstack subnet delete testfloat
openstack network delete testfloat


for i in $(openstack floating ip list --tags testvxlan -c ID -f value); do openstack floating ip delete $i; done
for i in $(openstack server list -c ID -f value); do openstack server delete $i; done
for i in $(openstack port list -c ID -f value); do openstack port delete $i; done
for i in $(openstack router list --tags testvxlan -c ID -f value); do openstack router delete $i; done
