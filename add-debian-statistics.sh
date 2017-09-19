#!/bin/sh

echo "installing packages"
apt-get -y install procinfo nmon sysstat

echo "enabling sar"
sed -i 's/ENABLED=.*/ENABLED="true"/' /etc/default/sysstat
service sysstat restart

echo "creating default configuration for nmon"
cat > /etc/profile.d/nmon.sh << EOF
# This starts monitors:
#  c = CPU by processor
#  m = Memory & Swap stats
#  d = Disk I/O Graphs
#  a = Disk Adapter
#  n = Network stats
#  t = Top Process Stats
export NMON=cmdant

# This alias is for PuTTY users that want to see lines rather than just lqqk
alias nmon="TERM=linux nmon"
EOF
