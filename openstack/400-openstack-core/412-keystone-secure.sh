#!/bin/sh

##############################################################################
# Configure  Keystone virtual host to use HTTPS on Controller host
##############################################################################
for i in private certs; do sudo mkdir -p /etc/keystone/ssl/$i; done

sudo cp \
  ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${CONTROLLER_FQDN}.crt \
  /etc/keystone/ssl/certs/keystone.pem
sudo cp \
  ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private/${CONTROLLER_FQDN}.key \
  /etc/keystone/ssl/private/keystonekey.pem
sudo cp \
  ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
  /etc/keystone/ssl/certs/ca.pem
sudo cp \
  ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private/${SSL_ROOT_CA_STRICT_NAME}.key \
  /etc/keystone/ssl/private/cakey.pem
sudo chown -R keystone:keystone /etc/keystone/ssl

cat << EOF | sudo tee -a /etc/apache2/sites-available/keystone.conf
SSLCertificateFile    /etc/ssl/certs/${CONTROLLER_FQDN}.crt
SSLCertificateKeyFile /etc/ssl/private/${CONTROLLER_FQDN}.key
EOF

sudo \
  sed -i 's|</VirtualHost>|\tSSLEngine on\n</VirtualHost>|' \
  /etc/apache2/sites-available/keystone.conf

sudo systemctl restart apache2
