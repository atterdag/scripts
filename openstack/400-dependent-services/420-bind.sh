#!/bin/sh

##############################################################################
# Install Bind on Controller host
##############################################################################
sudo apt-get install --yes --quiet bind9 bind9utils bind9-doc

sudo rndc-confgen -a -k designate -c /etc/bind/designate.key
sudo chmod 0640 /etc/bind/designate.key
sudo chown bind:bind /etc/bind/designate.key

sudo \
sed -i 's|^};|\
\tallow-new-zones yes;\
\trequest-ixfr no;\
\tlisten-on port 53 { any; };\
\t// recursion no;\
\tallow-query { any; };\
\tforward first;\
\tforwarders { 1.1.1.1; 1.0.0.1; };\
\tallow-query-cache { any; };\
};|' \
/etc/bind/named.conf.options

cat << EOF | sudo tee /etc/bind/designate.conf
include "/etc/bind/designate.key";

controls {
  inet 0.0.0.0 port 953
    allow { any; } keys { "designate"; };
};
EOF

cat << EOF | sudo tee /etc/bind/named.conf.local
include "/etc/bind/designate.conf";
EOF

sudo systemctl restart bind9
