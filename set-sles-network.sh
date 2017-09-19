#!/bin/bash
#
# Copy script to host first from main
# cp /net/main/srv/bin/sles-set-network.sh /tmp
#
# On new host run
# /tmp/sles-set-ip.sh db2-1.example.com 172.16.226.26 core
#

USAGE="usage: $0 -i <IP address> -f <FQDN> [ -v <core|dmz|windows> ] [-?]"

while getopts :i:f:v: opt; do
	case $opt in
		i)
			if [[ $OPTARG = -* ]]; then
				((OPTIND--))
				continue
			fi
			IP_ADDRESS=$OPTARG
			;;
		f)
			if [[ $OPTARG = -* ]]; then
				((OPTIND--))
				continue
			fi
			FQDN=$OPTARG
			;;
		v)
			if [[ $OPTARG = -* ]]; then
				((OPTIND--))
				continue
			fi
			VLAN=$OPTARG
			;;
		\?)
			echo $USAGE
			exit 1
			;;
	esac
done

if [ "$IP_ADDRESS" = "" ]; then echo; echo "missing IP address!"; echo; echo $USAGE; exit 1; fi
if [ "$FQDN" = "" ]; then echo; echo "missing FQDN!"; echo; echo $USAGE; exit 1; fi
if [ "$VLAN" = "" ]; then echo "*** no VLAN defined, so defaulting to \"core\""; VLAN=core; fi

if [[ "$(dirname $0)" =~ ^"/net/" ]]; then
	echo "*** OOPS! cannot run this script from network share. Instead copy it to /tmp, and run it again"
	echo "For your convenience we have prepared the command for you:"
	echo
	echo "cp $0 /tmp && /tmp/$(basename $0) -i $IP_ADDRESS -f $FQDN -v $VLAN"
	exit 1
fi

case $VLAN in
	core|*)
		DNS=172.16.226.20
		GATEWAY=172.16.226.254
		DOMAINSEARCH="example.com dmz.example.com example.lan"
		;;
	windows)
		DNS=172.16.227.20
		GATEWAY=172.16.227.254
		DOMAINSEARCH="example.lan example.com dmz.example.com"
	;;
	dmz)
		DNS=10.0.124.20
		GATEWAY=10.0.124.254
		DOMAINSEARCH="dmz.example.com example.com example.lan"
	;;
esac

HOSTNAME=$(echo $FQDN | awk -F . '{print $1}')
ID=$(yast lan list 2>&1 | tail -1 | awk '{print $1}')

echo "Network summary:"
echo -e "Interface ID:\t\t${ID}"
echo -e "IP address:\t\t$IP_ADDRESS"
echo -e "VLAN:\t\t\t$VLAN"
echo -e "Gateway:\t\t$GATEWAY"
echo -e "HOSTNAME:\t\t$HOSTNAME"
echo -e "FQDN:\t\t\t$FQDN"
echo -e "DNS server:\t\t$DNS"
echo -e "Domain search list:\t$DOMAINSEARCH"

echo "*** setting the FQDN in /etc/HOSTNAME"
echo $FQDN > /etc/HOSTNAME

echo "*** setting /etc/hostname from /etc/HOSTNAME"
hostname -F /etc/HOSTNAME

echo -e "*** adding $IP_ADDRESS\t$FQDN\t$HOSTNAME to /etc/hosts"
echo -e "$IP_ADDRESS\t$FQDN\t$HOSTNAME" >> /etc/hosts

echo "*** setting a fixed IP address for eth0"
yast lan edit id=$ID bootproto=none ip=$IP_ADDRESS prefix=24

echo "*** set the default route"
echo "default $GATEWAY – -" > /etc/sysconfig/network/routes

echo "*** setting DNS configuration in /etc/sysconfig/network/config"
sed -i 's/NETWORKMANAGER=.*/NETWORKMANAGER="no"/' /etc/sysconfig/network/config
sed -i 's/NETCONFIG_MODULES_ORDER=.*/NETCONFIG_MODULES_ORDER="dns-resolver dns-bind dns-dnsmasq nis ntp-runtime"/' /etc/sysconfig/network/config
sed -i 's/NETCONFIG_DNS_POLICY=.*/NETCONFIG_DNS_POLICY="auto"/' /etc/sysconfig/network/config
sed -i 's/NETCONFIG_DNS_FORWARDER=.*/NETCONFIG_DNS_FORWARDER="resolver"/' /etc/sysconfig/network/config
sed -i "s/NETCONFIG_DNS_STATIC_SEARCHLIST=.*/NETCONFIG_DNS_STATIC_SEARCHLIST=\"$DOMAINSEARCH\"/" /etc/sysconfig/network/config
sed -i "s/NETCONFIG_DNS_STATIC_SERVERS=.*/NETCONFIG_DNS_STATIC_SERVERS=\"$DNS\"/" /etc/sysconfig/network/config

echo "*** updating /etc/resolv.conf"
netconfig -f update
