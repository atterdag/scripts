#!/bin/sh

apt-get -y install autofs

if [ ! -d /etc/auto.master.d ]; then
    mkdir /etc/auto.master.d
fi

cat > /etc/auto.master.d/net.autofs << EOF
/net    /etc/auto.net --timeout=60
EOF

service autofs restart
