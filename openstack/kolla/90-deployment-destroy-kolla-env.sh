#!/bin/sh

echo '***'
echo '*** enable virtualenv'
echo '***'
if [[ -z ${WORKON_ON+x} ]]; then workon kolla; fi

echo '***'
echo '*** destroy kolla on Compute host'
echo '***'
kolla-ansible \
  --inventory /etc/kolla/inventory \
  --include-images \
  --yes-i-really-really-mean-it \
  destroy

echo '***'
echo '*** delete kolla configuration on Compute host'
echo '***'
sudo rm \
  --force \
  --recursive \
  /etc/kolla
