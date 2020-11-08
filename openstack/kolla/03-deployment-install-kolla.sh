#!/bin/sh

echo '***'
echo '*** setup virtualenvwrapper'
echo '***'
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
mkvirtualenv \
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
  ansible==2.9 \
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
if [[ ! -d  $HOME/src/openstack ]]; then mkdir $HOME/src/openstack; fi
for repo in kolla kolla-ansible octavia; do
  if [[ -d $HOME/src/openstack/${repo}/.git ]]; then
    (cd $HOME/src/openstack/${repo} && git pull)
  else
    git clone https://github.com/openstack/${repo} $HOME/src/openstack/${repo}
  fi
done

echo '***'
echo '*** install kolla'
echo '***'
for repo in kolla kolla-ansible; do
  pip install --upgrade $HOME/src/openstack/$repo
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
$HOME/src/openstack/octavia/diskimage-create/diskimage-create.sh
