#!/bin/bash

##############################################################################
# Install Apache on Controller host
##############################################################################
sudo apt-get --yes --quiet install \
  apache2

cat  <<EOF | sudo sed --file - --in-place /etc/apache2/ports.conf
s|Listen\s80|Listen ${OS_CONTROLLER_IP_ADDRESS}:80|
s|Listen\s443|Listen ${OS_CONTROLLER_IP_ADDRESS}:443|g
EOF

cat  <<EOF | sudo sed --file - --in-place /etc/apache2/conf-available/security.conf
s|^ServerTokens|#ServerTokens|
s|^#ServerTokens Minimal|ServerTokens Minimal|
s|^ServerSignature|#ServerSignature|
s|^#ServerSignature Off|ServerSignature Off|
EOF

echo "ServerName ${CONTROLLER_FQDN}" \
  | sudo tee /etc/apache2/conf-available/servername.conf

cat  <<EOF | sudo sed --file - --in-place /etc/apache2/sites-available/default-ssl.conf
s|SSLCertificateFile\s*/etc/ssl/certs/ssl-cert-snakeoil.pem|SSLCertificateFile /etc/ssl/certs/${CONTROLLER_FQDN}.crt|g
s|SSLCertificateKeyFile\s*/etc/ssl/private/ssl-cert-snakeoil.key|SSLCertificateKeyFile /etc/ssl/private/${CONTROLLER_FQDN}.key|g
EOF

sudo a2enconf security
sudo a2enconf servername
sudo a2enmod ssl
sudo a2ensite default-ssl.conf

# Make the apache runtime user a member of ssl-cert
sudo usermod -a -G ssl-cert www-data

sudo apachectl configtest
sudo systemctl restart apache2

# Check that apache is using the correct certificate
echo Q | openssl s_client -connect ${CONTROLLER_FQDN}:443 | openssl x509 -text
