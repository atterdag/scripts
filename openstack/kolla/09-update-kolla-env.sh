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
if [[ ! -d  $HOME/src ]]; then mkdir $HOME/src; fi
for repo in kolla kolla-ansible; do
  if [[ -d $HOME/src/${repo}/.git ]]; then
    (cd $HOME/src/${repo} && git pull)
  else
    git clone https://github.com/openstack/${repo} src/${repo}
  fi
done

echo '***'
echo '*** update kolla'
echo '***'
for repo in kolla kolla-ansible octavia; do
  pip install --upgrade src/$repo
done

kolla-ansible -i /etc/kolla/all-in-one upgrade && \
kolla-ansible -i /etc/kolla/all-in-one deploy-containers && \
kolla-ansible -i /etc/kolla/all-in-one prune-images --yes-i-really-really-mean-it
