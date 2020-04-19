#!/bin/sh

kolla-ansible -i /etc/kolla/all-in-one destroy --include-images --yes-i-really-really-mean-it \
&& sudo rm -fr /etc/kolla
