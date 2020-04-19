#!/bin/sh

kolla-ansible -i /etc/kolla/all-in-one bootstrap-servers \
&& kolla-ansible -i /etc/kolla/all-in-one prechecks \
&& kolla-ansible -i /etc/kolla/all-in-one deploy \
&& kolla-ansible -i /etc/kolla/all-in-one post-deploy
