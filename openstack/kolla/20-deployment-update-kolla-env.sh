#!/bin/sh

echo '***'
echo '*** enable virtualenv'
echo '***'
if [[ -z ${WORKON_ON+x} ]]; then workon kolla; fi

echo '***'
echo '*** import OpenStack variables from etcd'
echo '***'
source prepare-node.env

echo '***'
echo '*** clone kolla and kolla-ansible git repos'
echo '***'
if [[ ! -d  $HOME/src/openstack ]]; then mkdir $HOME/src/openstack; fi
for repo in kolla kolla-ansible; do
  if [[ -d $HOME/src/openstack/${repo}/.git ]]; then
    (cd $HOME/src/openstack/${repo} && git pull)
  else
    git clone https://github.com/openstack/${repo} $HOME/src/openstack/${repo}
  fi
done

echo '***'
echo '*** update kolla'
echo '***'
for repo in kolla kolla-ansible octavia; do
  pip install --upgrade $HOME/src/openstack/$repo
done

kolla-ansible \
  --inventory /etc/kolla/inventory \
  -vvv \
  upgrade && \
kolla-ansible \
  --inventory /etc/kolla/inventory \
  deploy-containers && \
kolla-ansible \
  --inventory /etc/kolla/inventory \
  prune-images --yes-i-really-really-mean-it
