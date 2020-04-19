#!/bin/sh

echo '***'
echo '*** setup virtualenvwrapper'
echo '***'
mkvirtualenv \
  --python=/usr/bin/python3 \
  kolla

# echo '***'
# echo '*** install ansible, kolla, and openstack client'
# echo '***'
# pip install -U \
#   ansible \
#   kolla-ansible \
#   python-openstackclient

echo '***'
echo '*** install ansible, and openstack client'
echo '***'
pip install -U \
  ansible \
  python-openstackclient

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
