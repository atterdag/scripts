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
  osc-placement \
  osc-placement-tree \
  python-barbicanclient \
  python-cinderclient \
  python-designateclient \
  python-glanceclient \
  python-heatclient \
  python-keystoneclient \
  python-neutronclient \
  python-novaclient \
  python-octaviaclient \
  python-openstackclient \
#  python-blazarclient \
#  python-magnumclient \
#  python-manilaclient \
#  python-mistralclient \
#  python-monascaclient \
#  python-saharaclient \
#  python-swiftclient \
#  python-troveclient \
#  python-zaqarclient \
#  python-zunclient \


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
for repo in kolla kolla-ansible octavia; do
  if [[ -d $HOME/src/${repo}/.git ]]; then
    (cd $HOME/src/${repo} && git pull)
  else
    git clone https://github.com/openstack/${repo} $HOME/src/${repo}
  fi
done

echo '***'
echo '*** install kolla'
echo '***'
for repo in kolla kolla-ansible; do
  pip install --upgrade $HOME/src/$repo
done

echo '***'
echo '*** install modules required to build octavia amphora-x64-haproxy image'
echo '***'
pip install \
  --isolated \
  --upgrade \
  git+https://git.openstack.org/openstack/diskimage-builder.git

echo '***'
echo '*** create amphora-x64-haproxy image'
echo '***'
$HOME/src/octavia/diskimage-create/diskimage-create.sh
