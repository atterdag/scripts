#!/bin/sh

cp /net/main/srv/common-setup/ssl/cacert.pem /usr/local/share/ca-certificates/Example-CA.crt

update-ca-certificates
