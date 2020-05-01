#!/bin/sh

kolla-ansible -i /etc/kolla/all-in-one reconfigure && \
kolla-ansible -i /etc/kolla/all-in-one upgrade && \
kolla-ansible -i /etc/kolla/all-in-one deploy-containers && \
kolla-ansible -i /etc/kolla/all-in-one prune-images
