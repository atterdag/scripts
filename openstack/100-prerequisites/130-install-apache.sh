#!/bin/bash

##############################################################################
# Install Apache on Controller host
##############################################################################
sudo apt-get --yes --quiet install \
  apache2

cat  <<EOF | sudo sed --file - --in-place /etc/apache2/ports.conf
s|Listen\s80|Listen ${MANAGEMENT_FQDN}:80|
EOF

cat  <<EOF | sudo sed --file - --in-place /etc/apache2/conf-available/security.conf
s|^ServerTokens|#ServerTokens|
s|^#ServerTokens Minimal|ServerTokens Minimal|
s|^ServerSignature|#ServerSignature|
s|^#ServerSignature Off|ServerSignature Off|
EOF

echo "ServerName ${MANAGEMENT_FQDN}" \
| sudo tee /etc/apache2/conf-available/servername.conf

sudo a2enconf security
sudo a2enconf servername

sudo apachectl configtest
sudo systemctl restart apache2
