#!/bin/sh
echo > /etc/apt/apt.conf
cat << EOF | sudo tee /etc/apt/sources.list
deb http://ftp.se.debian.org/debian/ stable main contrib non-free
deb-src http://ftp.se.debian.org/debian/ stable main contrib non-free
deb http://ftp.se.debian.org/debian-security/ stable/updates main contrib non-free
deb-src http://ftp.se.debian.org/debian-security/ stable/updates main contrib non-free
deb http://security.debian.org/ stable/updates main non-free
deb-src http://security.debian.org/ stable/updates main non-free
EOF
sudo apt-get update
