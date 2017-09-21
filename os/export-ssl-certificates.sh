#!/bin/sh
echo "*** Publishing PKI certificate store ***"
echo " * Updating CA CRL"
(cd /etc/ssl; openssl ca -config "/etc/ssl/openssl.cnf" -gencrl -out "/etc/ssl/crl/ca.crl" -passin pass:passw0rd)
echo " * Copying CA certs, and CRL to web server, and NFS share"
cp /etc/ssl/cacert.der /etc/ssl/cacert.pem /etc/ssl/crl/ca.crl /var/www/ssl/
cp /etc/ssl/cacert.der /etc/ssl/cacert.pem /etc/ssl/crl/ca.crl /srv/common-setup/ssl/
echo " * Copying public certificates to NFS share"
cp /etc/ssl/*-cert.* /srv/common-setup/ssl/
echo " * Copying private certificates to NFS share"
cp /etc/ssl/private/*-cert.p12 /srv/common-setup/ssl/
# yeah I know, but its just a test environment.
echo " * Copying PKCS#12 keystores to NFS share"
cp /etc/ssl/private/*-key.pem /srv/common-setup/ssl/
