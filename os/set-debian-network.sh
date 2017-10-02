#!/bin/bash
#
# Copy script to host first from main
# cp /net/main/srv/bin/debian-set-network.sh /tmp
#
# On new host run
# /tmp/debian-set-network.sh db2-1.example.com 172.16.226.26 core
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
		DOMAIN="example.com"
		DOMAINSEARCH="example.com dmz.example.com example.lan"
		;;
	windows)
		DNS=172.16.227.20
		GATEWAY=172.16.227.254
		DOMAIN="example.lan"
		DOMAINSEARCH="example.lan example.com dmz.example.com"
	;;
	dmz)
		DNS=10.0.124.20
		GATEWAY=10.0.124.254
		DOMAIN="dmz.example.com"
		DOMAINSEARCH="dmz.example.com example.com example.lan"
	;;
esac

HOSTNAME=$(echo $FQDN | awk -F . '{print $1}')
ID=$(netstat -i -a | awk '{print $1}' | egrep -v '^Kernel|^Iface|^lo' | head -1)

echo "Network summary:"
echo -e "Interface ID:\t\t$ID"
echo -e "IP address:\t\t$IP_ADDRESS"
echo -e "VLAN:\t\t\t$VLAN"
echo -e "Gateway:\t\t$GATEWAY"
echo -e "HOSTNAME:\t\t$HOSTNAME"
echo -e "FQDN:\t\t\t$FQDN"
echo -e "DNS server:\t\t$DNS"
echo -e "Domain search list:\t$DOMAINSEARCH"

echo "*** stopping autofs"
service autofs stop

echo "*** stopping networking"
service networking stop

echo "*** setting hostname in /etc/hostname"
echo $HOSTNAME > /etc/hostname

echo "*** setting hostname from /etc/hostname"
hostname -F /etc/hostname

echo "*** creating /etc/hosts"
echo -e "127.0.0.1\tlocalhost" > /etc/hosts
echo -e "127.0.1.1\t$HOSTNAME" >> /etc/hosts
echo -e "$IP_ADDRESS\t$FQDN" >> /etc/hosts
echo >> /etc/hosts
echo -e "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
echo -e "::1     localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo -e "ff02::1 ip6-allnodes" >> /etc/hosts
echo -e "ff02::2 ip6-allrouters" >> /etc/hosts

echo "*** setting a fixed IP address for $ID"
cat > /etc/network/interfaces << EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback
EOF

if [ ! -d /etc/network/interfaces.d ]; then
	mkdir /etc/network/interfaces.d
fi
echo -e "allow-hotplug $ID" > /etc/network/interfaces.d/$ID
echo -e "iface $ID inet static" >> /etc/network/interfaces.d/$ID
echo -e "\taddress $IP_ADDRESS" >> /etc/network/interfaces.d/$ID
echo -e "\tnetmask 255.255.255.0" >> /etc/network/interfaces.d/$ID
echo -e "\tgateway $GATEWAY" >> /etc/network/interfaces.d/$ID

if [ -d /etc/resolvconf/resolv.conf.d ]; then
	echo "*** setting DNS configuration in /etc/resolvconf/resolv.conf.d/base"
	cat > /etc/resolvconf/resolv.conf.d/base << EOF
nameserver ${DNS}
domain ${DOMAIN}
search ${DOMAINSEARCH}
EOF
else
	cat > /etc/resolv.conf << EOF
domain ${DOMAIN}
search ${DOMAINSEARCH}
nameserver ${DNS}
EOF
fi

sync

echo "*** starting networking"
service networking start

if [ -d /etc/resolvconf/resolv.conf.d ]; then
	echo "*** updating /etc/resolv.conf"
	service resolvconf restart
fi

echo "*** starting autofs"
service autofs start
