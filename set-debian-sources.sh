#!/bin/sh
echo > /etc/apt/apt.conf
cat > /etc/apt/sources.list << EOF
deb http://ftp.se.debian.org/debian/ stable main contrib non-free
deb-src http://ftp.se.debian.org/debian/ stable main contrib non-free
deb http://ftp.se.debian.org/debian-security/ stable/updates main contrib non-free
deb-src http://ftp.se.debian.org/debian-security/ stable/updates main contrib non-free
deb http://security.debian.org/ stable/updates main non-free
deb-src http://security.debian.org/ stable/updates main non-free
EOF
apt-get update
