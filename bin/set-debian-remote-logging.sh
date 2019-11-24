#!/bin/sh

cat << EOF | sudo tee /etc/rsyslog.d/loghost.conf
*.*                             @loghost.example.com
EOF

sudo service rsyslog restart
