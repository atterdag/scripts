#!/bin/sh

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
echo '*** install kolla'
echo '***'
pip install -U src/kolla
pip install -U src/kolla-ansible

kolla-ansible -i /etc/kolla/all-in-one reconfigure && \
kolla-ansible -i /etc/kolla/all-in-one upgrade && \
kolla-ansible -i /etc/kolla/all-in-one deploy-containers && \
kolla-ansible -i /etc/kolla/all-in-one prune-images --yes-i-really-really-mean-it
