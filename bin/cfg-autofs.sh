#!/bin/sh
cat > /etc/auto.nfs4 << EOF
main    -fstype=nfs4    main:/
files   -fstype=nfs4    files:/
EOF

cat > /etc/auto.master.d/net.autofs << EOF
/net    /etc/auto.nfs4 --timeout=60
EOF

service autofs restart
