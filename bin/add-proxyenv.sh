#!/bin/bash

username="proxyuser"
password="passw0rd"
host="cache.example.com"
port="3128"

export $(grep ID /etc/os-release)

case "$ID" in
	debian|ubuntu)
		echo "creating /etc/profile.d/proxyenv"
		cat > /etc/profile.d/proxyenv.sh << EOF
#!/bin/sh

username=$username
password=$password
host=$host
port=$port

function proxy_on (){
    echo "setting proxy variables"
    http_proxy="http://\${username}:\${password}@\${host}:\${port}"
    https_proxy="https://\${username}:\${password}@\${host}:\${port}"
    ftp_proxy="ftp://\${username}:\${password}@\${host}:\${port}"
    rsync_proxy="rsync://\${username}:\${password}@\${host}:\${port}"
    no_proxy="localhost,127.0.0.1,LocalAddress,example.com,example.lan"
    export http_proxy https_proxy ftp_proxy rsync_proxy no_proxy
}

function proxy_off (){
    echo "deleting proxy variables"
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset rsync_proxy
    unset no_proxy
}

proxy_on
EOF
		. /etc/profile.d/proxyenv.sh
		;;
	\"sles\")
		echo "adding proxy configuration to yast"
		yast proxy authentication clear
		yast proxy authentication \
		username=${username} \
		password=${password}
		yast proxy set \
		http=http://${host}:${port} \
		https=https://${host}:${port} \
		ftp=ftp://${host}:${port} \
		noproxy="localhost,127.0.0.1,LocalAddress,example.com,example.lan"
		yast2 proxy enable
		echo "You need to restart to make the proxy settings take effect!"
		;;
esac
