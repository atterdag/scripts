#!/bin/sh

cat > /etc/rsyslog.d/loghost.conf << EOF
*.*                             @loghost.example.com
EOF

service rsyslog restart
