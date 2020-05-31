#!/bin/sh

echo '***'
echo '*** create kolla management account'
echo '***'
sudo groupadd -g 42400 kolla
sudo useradd -u 42400 -g kolla -m -G docker -s /bin/bash kolla
cat <<EOF | sudo tee /etc/sudoers.d/kolla-ansible-users
kolla ALL=(ALL) NOPASSWD: ALL
EOF

echo '***'
echo '*** switch to kolla management account'
echo '***'
sudo --login --user kolla
