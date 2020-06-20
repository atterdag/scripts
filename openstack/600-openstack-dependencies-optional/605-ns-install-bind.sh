#!/bin/bash -x

##############################################################################
# Install Bind on ns host
##############################################################################
if [[ $CONTROLLER_FQDN != $NS_FQDN ]]; then
  ssh_cmd="ssh -o StrictHostKeyChecking=no ubuntu@${NS_IP_ADDRESS}"
else
  ssh_cmd=""
fi

$ssh_cmd sudo apt-get --yes --quiet install \
  bind9 \
  bind9utils \
  bind9-doc
$ssh_cmd sudo rndc-confgen -a -k designate -c /etc/bind/designate.key
$ssh_cmd sudo chmod 0640 /etc/bind/designate.key
$ssh_cmd sudo chown bind:bind /etc/bind/designate.key

sudo \
sed -i 's|^};|\
\tallow-new-zones yes;\n\
\trequest-ixfr no;\n\
\tlisten-on port 53 { any; };\n\
\t// recursion no;\n\
\tallow-query { any; };\n\
\tforward first;\n\
\tforwarders { 1.1.1.1; 1.0.0.1; };\n\
\tallow-query-cache { any; };\n\
};|' \
/etc/bind/named.conf.options

cat << EOF | $ssh_cmd sudo tee /etc/bind/designate.conf
include "/etc/bind/designate.key";

controls {
  inet 0.0.0.0 port 953
    allow { any; } keys { "designate"; };
};
EOF

cat << EOF | $ssh_cmd sudo tee /etc/bind/named.conf.local
include "/etc/bind/designate.conf";
EOF

$ssh_cmd sudo systemctl restart bind9

export ETCDCTL_DISCOVERY_SRV="$(hostname -d)"
if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read ETCD_ADMIN_PASS; fi
$ssh_cmd sudo cat /etc/bind/designate.key \
| base64 \
| etcdctl --username admin:"$ETCD_ADMIN_PASS" set /keystores/designate.key
