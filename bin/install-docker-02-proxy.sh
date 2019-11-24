#!/bin/sh

echo '***'
echo '*** setup environment'
echo '***'
HOSTNAME=$(hostname -s)

echo '***'
echo '*** adding forwarding proxy configuration to shell'
echo '***'
cat << EOF | sudo tee /etc/profile.d/proxyenv.sh
proxy_host="cache.example.com"
proxy_port="3128"

http_proxy="http://\${proxy_host}:\${proxy_port}";
https_proxy="https://\${proxy_host}:\${proxy_port}";
ftp_proxy="ftp://\${proxy_host}:\${proxy_port}";
no_proxy=localhost,127.0.0.1,LocalAddress,example.com,example.lan,$(hostname -i)

export http_proxy https_proxy ftp_proxy no_proxy;
EOF
. /etc/profile.d/proxyenv.sh
