#!/bin/sh
if [ "$1" = "" ]; then
	echo "syntax: $0 <ULB FQDN>"
	exit 1
fi

echo "create sysv script to set loopback address for edge"
cat > /etc/init.d/edge-ulb-loopback-$1 << EOF
#!/bin/sh
#
# Copyright (c) 2014 International Business Machines Corp.
#
# AUTHOR: Valdemar Lemche (DK20563) <valdemar.lemche@dk.ibm.com>
#
# DESCRIPTION:
# SysV init scripts for add/remove of loopback address for IBM WebSphere Edge ULB.
#
### BEGIN INIT INFO
# Provides:       edge-ulb-loopback
# Required-Start: \$network
# X-UnitedLinux-Should-Start: network
# Required-Stop:  \$network
# Default-Start:  2 3 5
# Default-Stop:   0 1 6
# Description:    IBM WebSphere Edge ULB loopback configuration
### END INIT INFO


### CHANGE THESE VARIABLES TO FIT YOUR ENVIRONMENT ###

ULB_HOST="$1"



### DON'T CHANGE ANYTHING BELOW UNLESS YOU KNOW WHAT YOU'RE DOING ###

if [ ! -x /sbin/ip ]; then
       echo "/sbin/ip is missing";
       exit 1;
fi;

LOG="/var/log/rcedge-ulb-loopback.log"
ULB_HOST_IP=\$(host \$ULB_HOST | sed 's/^.*has address //g')

case "\$1" in
    start)
        echo "\`date\` *** start requested ***" > \${LOG} 2>&1
        printf "Adding Edge Cluter IP to loopback:"
        printf " ip"
        ip -4 addr add \${ULB_HOST_IP}/32 dev lo >> \${LOG} 2>&1
        echo "."
        echo "\`date\` *** start completed ***" >> \${LOG} 2>&1
        ;;
    stop)
        echo "\`date\` *** shutdown requested ***" > \${LOG} 2>&1
        printf "Removing Edge Cluter IP to loopback:"
        printf " ip"
        ip -4 addr delete \${ULB_HOST_IP}/32 dev lo >> \${LOG} 2>&1
        echo "."
        echo "\`date\` *** shutdown completed ***" >> \${LOG} 2>&1
        ;;
    restart)
        \$0 stop
        \$0 start
        ;;
    status)
        /sbin/ip address list lo
        ;;
    *)
        echo "Usage: \$0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0
EOF

echo "make it executable"
chmod +x  /etc/init.d/edge-ulb-loopback-$1

echo "define that they should start at system boot"
chkconfig edge-ulb-loopback-$1 on
