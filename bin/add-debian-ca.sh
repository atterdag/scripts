#!/bin/sh

sudo cp /net/main/srv/common-setup/ssl/cacert.pem /usr/local/share/ca-certificates/Example-CA.crt

sudo update-ca-certificates
