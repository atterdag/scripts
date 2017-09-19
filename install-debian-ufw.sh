#!/bin/sh
apt-get -y install ufw
ufw allow OpenSSH
ufw enable
