#!/bin/sh

echo '***'
echo '*** reconfigure kolla'
echo '***'
kolla-ansible \
  --inventory /etc/kolla/inventory \
  reconfigure
