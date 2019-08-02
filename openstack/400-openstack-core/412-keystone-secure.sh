#!/bin/bash

##############################################################################
# Configure  Keystone virtual host to use HTTPS on Controller host
##############################################################################
cat << EOF | sudo tee -a /etc/apache2/sites-available/keystone.conf
SSLCertificateFile    /etc/ssl/certs/${CONTROLLER_FQDN}.crt
SSLCertificateKeyFile /etc/ssl/private/${CONTROLLER_FQDN}.key
EOF

sudo \
  sed -i 's|</VirtualHost>|\tSSLEngine on\n</VirtualHost>|' \
  /etc/apache2/sites-available/keystone.conf

sudo systemctl restart apache2
