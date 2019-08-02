#!/bin/bash

##############################################################################
# Install 389 Directory Server
##############################################################################
cat << EOF | sudo tee /etc/apache2/sites-available/${SSL_ROOT_CA_FQDN}.conf
<VirtualHost ${SSL_ROOT_CA_FQDN}:80>
    ServerName ${SSL_ROOT_CA_FQDN}
    DocumentRoot ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs
    <Directory ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/${SSL_ROOT_CA_FQDN}-error.log
    CustomLog \${APACHE_LOG_DIR}/${SSL_ROOT_CA_FQDN}-access.log combined
</VirtualHost>
# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF

sudo a2ensite ${SSL_ROOT_CA_FQDN}

sudo apachectl restart
