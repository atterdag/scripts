#!/bin/sh
sudo apt-get -y install ufw
sudo ufw allow OpenSSH
sudo ufw enable
