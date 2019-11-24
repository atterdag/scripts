#!/bin/bash
echo "*** Importing common CA files ***"
echo " * copying cacert.pem, and cacert.der to /etc/ssl"
sudo cp /net/main/srv/common-setup/ssl/cacert.{der,pem} /etc/ssl/
echo " * copying ca.crl to /etc/ssl/crl.pem"
sudo cp /net/main/srv/common-setup/ssl/ca.crl /etc/ssl/crl.pem
echo
echo "*** Importing personal certificates ***"
echo " * copying public certificates ${HOSTNAME}.example.com-cert.pem, and ${HOSTNAME}.example.com-cert.der to /etc/ssl"
sudo cp /net/main/srv/common-setup/ssl/${HOSTNAME}.example.com-cert.{der,pem} /etc/ssl/
echo " * copying private key ${HOSTNAME}.example.com-key.pem to /etc/ssl/private"
sudo cp /net/main/srv/common-setup/ssl/${HOSTNAME}.example.com-key.pem /etc/ssl/private/

if [ ! -L /etc/ssl/demoCA ]; then
    echo "*** Creating symlink from /etc/ssl/demoCA to /etc/ssl ***"
    sudo ln -s /etc/ssl /etc/ssl/demoCA
fi
