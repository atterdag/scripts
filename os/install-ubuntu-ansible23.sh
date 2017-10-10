#!/bin/sh
sudo apt-get install software-properties-common
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
#sudo add-apt-repository ppa:ansible/ansible-2.3
cat << EOF | sudo tee /etc/apt/sources.list.d/ansible-2.3.list
deb http://ppa.launchpad.net/ansible/ansible-2.3/ubuntu xenial main 
deb-src http://ppa.launchpad.net/ansible/ansible-2.3/ubuntu xenial main 
EOF
sudo apt-get update
sudo apt-get install ansible
