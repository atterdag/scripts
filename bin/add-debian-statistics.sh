#!/bin/sh

echo "installing packages"
sudo apt-get -y install procinfo nmon sysstat

echo "enabling sar"
sudo sed -i 's/ENABLED=.*/ENABLED="true"/' /etc/default/sysstat
sudo service sysstat restart

echo "creating default configuration for nmon"
cat <<EOF | sudo tee /etc/profile.d/nmon.sh
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
