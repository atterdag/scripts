#!/bin/bash

for i in $(openstack server list -c ID -f value); do openstack server delete $i; done
for i in $(openstack port list -c ID -f value); do openstack port delete $i; done
