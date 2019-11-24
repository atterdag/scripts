#!/bin/sh

sudo apt-get -y install autofs

if [ ! -d /etc/auto.master.d ]; then
    sudo mkdir /etc/auto.master.d
fi

cat <<EOF | sudo tee /etc/auto.master.d/net.autofs
/net    /etc/auto.net --timeout=60
EOF

sudo service autofs restart
