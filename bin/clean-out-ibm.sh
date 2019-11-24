#!/bin/sh

sudo killall -15 java
sudo killall -15 httpd
sleep 15
sudo killall -12 java
sudo killall -12 httpd
sleep 15
sudo killall -9 java
sudo killall -9 httpd
sleep 15
sudo /net/main/srv/bin/slibclean
sudo sync
sudo rm -fr /opt/IBM
sudo rm -fr /opt/ibm
sudo rm -fr /opt/.ibm
sudo rm -fr /var/ibm/
sudo rm -fr /var/db2/
sudo rm -fr /root/*logs
sudo rm -fr /root/vpd.properties
sudo rm -fr /root/.ITLMRegistry
sudo rm -fr /root/.ibm
sudo rm -fr /root/inst-sys
sudo rm -fr /root/isus
sudo rm -fr /tmp/ismp*
sudo rm -fr /tmp/*install*.txt
sudo rm -fr /tmp/*.tmp
sudo rm -fr /tmp/*.log
sudo rm -fr /tmp/*.xml
sudo rm -fr /tmp/*.txt
sudo rm -fr /tmp/*.py
sudo rm -fr /opt/lost+found/*
sudo userdel -r ihs
sudo groupdel ihs
sudo userdel -r was
sudo groupdel was
