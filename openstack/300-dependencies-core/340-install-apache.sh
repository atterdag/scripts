#!/bin/bash

##############################################################################
# Install Apache on Controller host
##############################################################################
sudo apt-get --yes --quiet install \
  apache2

export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault login -method=userpass username=user password=$(cat ~/.VAULT_USER_PASS)

vault kv get --field=data keystores/${CONTROLLER_FQDN}.p12 \
| tr -d '\n' \
| base64 --decode \
> ${CONTROLLER_FQDN}.p12

openssl pkcs12 \
  -in ${CONTROLLER_FQDN}.p12 \
  -passin pass:${CONTROLLER_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| sudo tee /etc/ssl/certs/${CONTROLLER_FQDN}.crt

openssl pkcs12 \
  -in ${CONTROLLER_FQDN}.p12 \
  -passin pass:${CONTROLLER_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| sudo tee /etc/ssl/private/${CONTROLLER_FQDN}.key

# Ensure that the ssl-cert group owns the keypair
sudo chown root:ssl-cert \
  /etc/ssl/certs/${CONTROLLER_FQDN}.crt \
  /etc/ssl/private/${CONTROLLER_FQDN}.key

# Restrict access to the keypair
sudo chmod 644 /etc/ssl/certs/${CONTROLLER_FQDN}.crt
sudo chmod 640 /etc/ssl/private/${CONTROLLER_FQDN}.key

cat  <<EOF | sudo sed --file - --in-place /etc/apache2/ports.conf
s|Listen\s80|Listen ${CONTROLLER_IP_ADDRESS}:80|
s|Listen\s443|Listen ${CONTROLLER_IP_ADDRESS}:443|g
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
