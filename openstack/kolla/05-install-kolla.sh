#!/bin/sh

echo '***'
echo '*** setup virtualenvwrapper'
echo '***'
mkvirtualenv \
  --python=/usr/bin/python3 \
  kolla

echo '***'
echo '*** update pip in virtualenv'
echo '***'
pip install -U \
  pip

echo '***'
echo '*** install ansible, and openstack client'
echo '***'
pip install -U \
  ansible \
  osc-placement-tree \
  osc-placement
  python-openstackclient

echo '***'
echo '*** bash completion on Controller host'
echo '***'
openstack complete \
| sudo tee /etc/bash_completion.d/osc.bash_completion \
> /dev/null
source /etc/bash_completion

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
pip install src/kolla
pip install src/kolla-ansible
