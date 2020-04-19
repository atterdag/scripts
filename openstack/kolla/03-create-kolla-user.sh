#!/bin/sh

echo '***'
echo '*** create kolla management account'
echo '***'
sudo useradd -m -U -G docker -s /bin/bash kolla
cat <<EOF | sudo tee /etc/sudoers.d/kolla-ansible-users
kolla ALL=(ALL) NOPASSWD: ALL
EOF

echo '***'
echo '*** switch to kolla management account'
echo '***'
sudo --login --user kolla
