#!/bin/sh

killall -15 java
killall -15 httpd
sleep 15
killall -12 java
killall -12 httpd
sleep 15
killall -9 java
killall -9 httpd
sleep 15
/net/main/srv/bin/slibclean
sync
rm -fr /opt/IBM
rm -fr /opt/ibm
rm -fr /opt/.ibm
rm -fr /var/ibm/
rm -fr /var/db2/
rm -fr /root/*logs
rm -fr /root/vpd.properties
rm -fr /root/.ITLMRegistry
rm -fr /root/.ibm
rm -fr /root/inst-sys
rm -fr /root/isus
rm -fr /tmp/ismp*
rm -fr /tmp/*install*.txt
rm -fr /tmp/*.tmp
rm -fr /tmp/*.log
rm -fr /tmp/*.xml
rm -fr /tmp/*.txt
rm -fr /tmp/*.py
rm -fr /opt/lost+found/*
userdel -r ihs
groupdel ihs
userdel -r was
groupdel was
