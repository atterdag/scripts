#!/bin/sh

##############################################################################
# Install Apache on Controller host
##############################################################################
sudo apt-get --yes install apache2

sudo sed -i "s|Listen\s80|Listen ${CONTROLLER_IP_ADDRESS}:80|" /etc/apache2/ports.conf
sudo sed -i "s|Listen\s443|Listen ${CONTROLLER_IP_ADDRESS}:443|g" /etc/apache2/ports.conf

sudo sed -i 's|^ServerTokens|#ServerTokens|' /etc/apache2/conf-available/security.conf
sudo sed -i 's|^#ServerTokens Minimal|ServerTokens Minimal|' /etc/apache2/conf-available/security.conf
sudo sed -i 's|^ServerSignature|#ServerSignature|' /etc/apache2/conf-available/security.conf
sudo sed -i 's|^#ServerSignature Off|ServerSignature Off|' /etc/apache2/conf-available/security.conf
sudo a2enconf security

echo "ServerName ${CONTROLLER_FQDN}" | sudo tee /etc/apache2/conf-available/servername.conf
sudo a2enconf servername

sudo a2enmod ssl
sudo sed -i "s|SSLCertificateFile\s*/etc/ssl/certs/ssl-cert-snakeoil.pem|SSLCertificateFile /etc/ssl/certs/${CONTROLLER_FQDN}.crt|g" /etc/apache2/sites-available/default-ssl.conf
#" Atom Unix shell botches the interpretation of the sed command, and misses the closing double qoute
sudo sed -i "s|SSLCertificateKeyFile\s*/etc/ssl/private/ssl-cert-snakeoil.key|SSLCertificateKeyFile /etc/ssl/private/${CONTROLLER_FQDN}.key|g" /etc/apache2/sites-available/default-ssl.conf
#" Atom Unix shell botches the interpretation of the sed command, and misses the closing double qoute
sudo a2ensite default-ssl.conf

# Make the apache runtime user a member of ssl-cert
sudo usermod -a -G ssl-cert www-data

sudo apachectl configtest
sudo systemctl restart apache2

# Check that apache is using the correct certificate
echo Q | openssl s_client -connect ${CONTROLLER_FQDN}:443 | openssl x509 -text
