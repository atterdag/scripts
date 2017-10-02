#!/bin/sh
#
# Copy script to host first from main
# cp /net/main/srv/bin/set-rhel-network.sh /tmp
#
# On new host run
# /tmp/set-rhel-network.sh -f db2-1.example.com -i 172.16.226.26 -v core
#
# setenforce 0
# iptables -P INPUT ACCEPT
# iptables -P OUTPUT ACCEPT
# iptables -P FORWARD ACCEPT

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

case $VLAN in
	core)
		DNS=172.16.226.20
		GATEWAY=172.16.226.254
		DOMAINSEARCH="example.com,dmz.example.com,example.lan"
		;;
	windows)
		DNS=172.16.227.20
		GATEWAY=172.16.227.254
		DOMAINSEARCH="example.lan,example.com,dmz.example.com"
	;;
	dmz)
		DNS=10.0.124.20
		GATEWAY=10.0.124.254
		DOMAINSEARCH="dmz.example.com,example.com,example.lan"
	;;
esac

HOSTNAME=$(echo $FQDN | awk -F . '{print $1}')
ID=$(nmcli connection | awk '{print $1}' | grep -v NAME)

echo "Network summary:"
echo "Interface ID:       $ID"
echo "IP address:         $IP_ADDRESS"
echo "VLAN:               $VLAN"
echo "Gateway:            $GATEWAY"
echo "HOSTNAME:           $HOSTNAME"
echo "FQDN:               $FQDN"
echo "DNS server:         $DNS"
echo "Domain search list: $DOMAINSEARCH"

echo "*** adding FQDN to /etc/hostname"
echo $FQDN > /etc/hostname

echo "*** adding entry to /etc/hosts"
echo -e "${IP}\t${FQDN}\t${HOSTNAME}" >> /etc/hosts

echo "*** configuring network, and DNS settings"
nmcli connection mod id $ID connection.autoconnect yes ipv4.method manual ipv4.dns $DNS ipv4.dns-search $DOMAINSEARCH ipv4.addresses ${IP_ADDRESS}/24 ipv4.gateway $GATEWAY

echo
echo "*****************************"
echo "*** Now reboot the system ***"
echo "*****************************"
echo
