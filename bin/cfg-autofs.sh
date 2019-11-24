#!/bin/sh
cat <<EOF | sudo tee /etc/auto.nfs4
main    -fstype=nfs4    main:/
files   -fstype=nfs4    files:/
EOF

cat <<EOF | sudo tee /etc/auto.master.d/net.autofs
/net    /etc/auto.nfs4 --timeout=60
EOF

sudo service autofs restart
