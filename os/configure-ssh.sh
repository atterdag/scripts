#!/bin/sh
sed -i 's/PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config
service ssh restart
