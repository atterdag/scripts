#!/bin/sh
sudo sed -i 's/PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config
sudo service ssh restart
