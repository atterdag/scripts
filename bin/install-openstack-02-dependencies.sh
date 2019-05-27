#!/bin/sh

##############################################################################
# Enable the OpenStack repository
##############################################################################
sudo apt-get --yes install software-properties-common
sudo add-apt-repository --yes cloud-archive:rocky
sudo apt-get update
sudo apt-get --yes dist-upgrade

##############################################################################
# Install dependencies
##############################################################################
sudo apt-get --yes install \
  arptables \
  ebtables \
  lvm2 \
  python-pip \
  thin-provisioning-tools

##############################################################################
# Install NTP on Controller host
##############################################################################
sudo apt-get --yes install chrony

sudo mv /etc/chrony/chrony.conf /etc/chrony/chrony.conf.org
cat << EOT | sudo tee /etc/chrony/chrony.conf
allow ${NETWORK_CIDR}
EOT
sudo chmod 0644 /etc/chrony/chrony.conf
sudo chown root:root /etc/chrony/chrony.conf
sudo systemctl restart chrony

##############################################################################
# Install NTP on Compute host
##############################################################################
sudo apt-get --yes install chrony

sudo mv /etc/chrony/chrony.conf /etc/chrony/chrony.conf.org
cat << EOT | sudo tee /etc/chrony/chrony.conf
server ${CONTROLLER_IP_ADDRESS}
EOT
sudo chmod 0644 /etc/chrony/chrony.conf
sudo chown root:root /etc/chrony/chrony.conf
sudo systemctl restart chrony

##############################################################################
# Install OpenStack command line tool on Controller host
##############################################################################
sudo apt-get --yes install python-openstackclient python-oslo.log

##############################################################################
# Bash completion on Controller host
##############################################################################
source /var/lib/openstack/admin-openrc
openstack complete | sudo tee /etc/bash_completion.d/osc.bash_completion > /dev/null
source /etc/bash_completion

##############################################################################
# Install Database on Controller host
##############################################################################
sudo apt-get --yes install mariadb-server python-pymysql

cat << EOF | sudo tee /etc/mysql/mariadb.conf.d/99-openstack.cnf
[mysqld]
# bind-address = ${CONTROLLER_IP_ADDRESS}
bind-address = 0.0.0.0

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
sudo systemctl restart mysql

sudo mysqladmin password "${ROOT_DBPASS}"
cat << EOF | sudo tee /var/lib/openstack/mysql_secure_installation.sql
# SQL script performing actions in mysql_secure_installation
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
# Default mariadb doesn't create test database
#DROP DATABASE test;
#DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF
sudo chmod 0600 /var/lib/openstack/mysql_secure_installation.sql
sudo cat /var/lib/openstack/mysql_secure_installation.sql | sudo mysql --host=localhost --user=root
echo "SELECT Host,User,Password FROM mysql.user WHERE User='root';" | sudo mysql --host=localhost --port=3306 --user=root --password="${ROOT_DBPASS}"

##############################################################################
# Install Queue Manager on Controller host
##############################################################################
sudo apt-get --yes install rabbitmq-server

sudo rabbitmqctl add_user openstack $RABBIT_PASS
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"

##############################################################################
# Install Memcached on Controller
##############################################################################
sudo apt-get --yes install memcached python-memcache

sudo sed -i "s/^-l\s.*$/-l ${CONTROLLER_IP_ADDRESS}/" /etc/memcached.conf
sudo systemctl restart memcached

##############################################################################
# Install Apache on Controller host
##############################################################################
sudo apt-get --yes install apache2

sudo sed -i 's|^ServerTokens|#ServerTokens|' /etc/apache2/conf-available/security.conf
sudo sed -i 's|^#ServerTokens Minimal|ServerTokens Minimal|' /etc/apache2/conf-available/security.conf
sudo sed -i 's|^ServerSignature|#ServerSignature|' /etc/apache2/conf-available/security.conf
sudo sed -i 's|^#ServerSignature Off|ServerSignature Off|' /etc/apache2/conf-available/security.conf
sudo a2enconf security

echo "ServerName ${CONTROLLER_FQDN}" | sudo tee /etc/apache2/conf-available/servername.conf
sudo a2enconf servername

sudo systemctl reload apache2

##############################################################################
# Install Etcd on Controller host
##############################################################################
sudo apt-get install --yes etcd

sudo mv /etc/default/etcd /etc/default/etcd.orig
cat << EOF | sudo tee /etc/default/etcd
ETCD_NAME="${CONTROLLER_FQDN}"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
ETCD_INITIAL_CLUSTER="${CONTROLLER_FQDN}=http://${CONTROLLER_IP_ADDRESS}:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${CONTROLLER_IP_ADDRESS}:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://${CONTROLLER_IP_ADDRESS}:2379"
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
ETCD_LISTEN_CLIENT_URLS="http://${CONTROLLER_IP_ADDRESS}:2379"
EOF
sudo systemctl enable etcd
sudo systemctl start etcd

##############################################################################
# Install Bind on Controller host
##############################################################################
sudo apt-get install --yes --quiet bind9 bind9utils bind9-doc

sudo rndc-confgen -a -k designate -c /etc/bind/designate.key
sudo chmod 0640 /etc/bind/designate.key
sudo chown bind:bind /etc/bind/designate.key

sudo \
sed -i 's|^};|\
\tallow-new-zones yes;\
\trequest-ixfr no;\
\tlisten-on port 53 { any; };\
\trecursion no;\
\tallow-query { any; };\
};|' \
/etc/bind/named.conf.options

cat << EOF | sudo tee /etc/bind/designate.conf
include "/etc/bind/designate.key";

controls {
  inet 0.0.0.0 port 953
    allow { any; } keys { "designate"; };
};
EOF

cat << EOF | sudo tee /etc/bind/named.conf.local
include "/etc/bind/designate.conf";
EOF

sudo systemctl restart bind9

##############################################################################
# Install OpenSSL on Controller host
##############################################################################
sudo apt-get install --yes --quiet openssl

sudo mkdir -p ${SSL_CA_DIR}/{certs,crl,reqs,newcerts,private}
sudo chown -R root:ssl-cert ${SSL_CA_DIR}/private
sudo chmod 0750 ${SSL_CA_DIR}/private
sed 's|./demoCA|${SSL_CA_DIR}|g' /etc/ssl/openssl.cnf | sudo tee ${SSL_CA_DIR}/openssl.cnf
echo "01" | sudo tee ${SSL_CA_DIR}/serial
echo "01" | sudo tee ${SSL_CA_DIR}/crlnumber
sudo touch ${SSL_CA_DIR}/index.txt

cat << EOF | sudo tee ${SSL_CA_DIR}/openssl.cnf
HOME                           = ${SSL_CA_DIR}
RANDFILE                       = ${OPENSSL_CA_DIR}/.rnd
oid_section                    = new_oids

[ new_oids ]
tsa_policy1                    = 1.2.3.4.1
tsa_policy2                    = 1.2.3.4.5.6
tsa_policy3                    = 1.2.3.4.5.7

[ ca ]
default_ca                     = CA_default

[ CA_default ]
dir                            = ${SSL_CA_DIR}
certs                          = \$dir/certs
crl_dir                        = \$dir/crl
database                       = \$dir/index.txt
new_certs_dir                  = \$dir/newcerts
certificate                    = \$dir/certs/ca.crt
serial                         = \$dir/serial
crlnumber                      = \$dir/crlnumber
crl                            = \$dir/ca.crl
private_key                    = \$dir/private/ca.key
RANDFILE                       = \$dir/private/.rand
x509_extensions                = usr_cert
name_opt                       = ca_default
cert_opt                       = ca_default
copy_extensions                = copy
crl_extensions                 = crl_ext
default_days                   = 3650
default_crl_days               = 30
default_md                     = default
preserve                       = no
policy                         = policy_match

[ policy_match ]
countryName                    = match
stateOrProvinceName            = match
organizationName               = match
organizationalUnitName         = optional
commonName                     = supplied
emailAddress                   = optional

[ policy_anything ]
countryName                    = optional
stateOrProvinceName            = optional
localityName                   = optional
organizationName               = optional
organizationalUnitName         = optional
commonName                     = supplied
emailAddress                   = optional

[ req ]
default_bits                   = 4096
default_keyfile                = privkey.pem
distinguished_name             = req_distinguished_name
attributes                     = req_attributes
x509_extensions                = v3_ca
string_mask                    = utf8only
req_extensions                 = v3_req

[ req_distinguished_name ]
countryName                    = Country Name (2 letter code)
countryName_default            = $SSL_COUNTRY_NAME
countryName_min                = 2
countryName_max                = 2
stateOrProvinceName            = State or Province Name (full name)
stateOrProvinceName_default    = $SSL_STATE
localityName                   = Locality Name (eg, city)
0.organizationName             = Organization Name (eg, company)
0.organizationName_default     = $SSL_ORGANIZATION_NAME
organizationalUnitName         = Organizational Unit Name (eg, section)
organizationalUnitName_default = $SSL_ORGANIZATIONAL_UNIT_NAME
commonName                     = Common Name (e.g. server FQDN or YOUR name)
commonName_max                 = 64
emailAddress                   = Email Address
emailAddress_max               = 64

[ req_attributes ]
challengePassword              = A challenge password
challengePassword_min          = 4
challengePassword_max          = 20
unstructuredName               = An optional company name

[ usr_cert ]
basicConstraints=CA:FALSE
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid,issuer
nsBaseUrl                      = ${SSL_BASE_URL}
nsCaRevocationUrl              = ${SSL_BASE_URL}/ca.crl
nsRevocationUrl                = ${SSL_BASE_URL}/revocation.html
nsRenewalUrl                   = ${SSL_BASE_URL}/renewal.html
nsCaPolicyUrl                  = ${SSL_BASE_URL}/policy.html
issuerAltName                  = @ca_ials
crlDistributionPoints          = @crl_distpoints

[ ca_sans ]
DNS.1                          = ca.${DNS_DOMAIN}

[ ca_ials ]
URI.1                          = $SSL_BASE_URL

[ crl_distpoints ]
URI.1                          = ${SSL_BASE_URL}/ca.crl

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage                       = nonRepudiation, digitalSignature, keyEncipherment

[ v3_ca ]
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid:always,issuer:always
basicConstraints               = critical,CA:true
keyUsage                       = cRLSign, keyCertSign
nsCertType                     = sslCA, emailCA
subjectAltName                 = email:copy
subjectAltName                 = @ca_sans
nsBaseUrl                      = ${SSL_BASE_URL}
nsCaRevocationUrl              = ${SSL_BASE_URL}/ca.crl
nsRevocationUrl                = ${SSL_BASE_URL}/revocation.html
nsRenewalUrl                   = ${SSL_BASE_URL}/renewal.html
nsCaPolicyUrl                  = ${SSL_BASE_URL}/policy.html
issuerAltName                  = issuer:copy
issuerAltName                  = @ca_ials
crlDistributionPoints          = @crl_distpoints

[ crl_ext ]
issuerAltName                  = issuer:copy
authorityKeyIdentifier         = keyid:always

[ proxy_cert_ext ]
basicConstraints               = CA:FALSE
nsCertType                     = server
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid:always,issuer
proxyCertInfo                  = critical,language:id-ppl-anyLanguage,pathlen:3,policy:foo

[ tsa ]
default_tsa                    = tsa_config1

[ tsa_config1 ]
dir                            = ${SSL_CA_DIR}
serial                         = \$dir/tsaserial
crypto_device                  = builtin
signer_cert                    = \$dir/tsacert.pem
certs                          = \$dir/cacert.pem
signer_key                     = \$dir/private/tsakey.pem
signer_digest                  = sha256
default_policy                 = tsa_policy1
other_policies                 = tsa_policy2, tsa_policy3
digests                        = sha1, sha256, sha384, sha512
accuracy                       = secs:1, millisecs:500, microsecs:100
clock_precision_digits         = 0
ordering                       = yes
tsa_name                       = yes
ess_cert_id_chain              = no
EOF

# Generate new CA key, and certifiate
sudo openssl req \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -days 3650 \
  -extensions v3_ca \
  -keyform PEM \
  -keyout ${SSL_CA_DIR}/private/ca.key \
  -new \
  -newkey rsa:4096  \
  -out ${SSL_CA_DIR}/certs/ca.crt \
  -outform PEM \
  -passin pass:${CA_PASSWORD} \
  -passout pass:${CA_PASSWORD} \
  -sha512 \
  -subj "/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${SSL_CA_NAME}" \
  -subject \
  -text \
  -verbose \
  -x509

# Generate controller node key, and certifiate
sudo su -c "openssl req \
  -config <(cat ${SSL_CA_DIR}/openssl.cnf; \
    printf \"[SAN]\nsubjectAltName=DNS:${COMPUTE_FQDN}\") \
  -keyout ${SSL_CA_DIR}/private/${CONTROLLER_FQDN}.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_CA_DIR}/reqs/${CONTROLLER_FQDN}.csr \
  -reqexts SAN \
  -sha256 \
  -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${CONTROLLER_FQDN}\" \
  -subject \
  -text"

yes | sudo openssl ca \
  -cert ${SSL_CA_DIR}/certs/ca.crt \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -days 365 \
  -in ${SSL_CA_DIR}/reqs/${CONTROLLER_FQDN}.csr \
  -keyfile ${SSL_CA_DIR}/private/ca.key \
  -keyform PEM \
  -out ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.crt \
  -passin pass:${CA_PASSWORD}

# Generate compute node key, and certifiate
sudo su -c "openssl req \
  -config <(cat ${SSL_CA_DIR}/openssl.cnf; \
    printf \"[SAN]\nsubjectAltName=DNS:${COMPUTE_FQDN}\") \
  -keyout ${SSL_CA_DIR}/private/${COMPUTE_FQDN}.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_CA_DIR}/reqs/${COMPUTE_FQDN}.csr \
  -reqexts SAN \
  -sha256 \
  -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${COMPUTE_FQDN}\" \
  -subject \
  -text"

yes | sudo openssl ca \
  -cert ${SSL_CA_DIR}/certs/ca.crt \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -days 365 \
  -in ${SSL_CA_DIR}/reqs/${COMPUTE_FQDN}.csr \
  -keyfile ${SSL_CA_DIR}/private/ca.key \
  -keyform PEM \
  -out ${SSL_CA_DIR}/certs/${COMPUTE_FQDN}.crt \
  -passin "pass:${CA_PASSWORD}"

# Generate alm proxy key, and certifiate
sudo openssl ca \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -revoke ${SSL_CA_DIR}/certs/alm.se.lemche.net.crt \
  -passin "pass:${CA_PASSWORD}"

sudo openssl req \
  -config <(cat ${SSL_CA_DIR}/openssl.cnf; \
    printf "[SAN]\nsubjectAltName=DNS:alm.se.lemche.net,DNS:joxit.se.lemche.net,DNS:registry.se.lemche.net,DNS:gogs.se.lemche.net,DNS:awx.se.lemche.net") \
  -keyout ${SSL_CA_DIR}/private/alm.se.lemche.net.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_CA_DIR}/reqs/alm.se.lemche.net.csr \
  -reqexts SAN \
  -sha256 \
  -subj "/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=alm.se.lemche.net" \
  -subject \
  -text

yes | sudo openssl ca \
  -cert ${SSL_CA_DIR}/certs/ca.crt \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -days 365 \
  -in ${SSL_CA_DIR}/reqs/alm.se.lemche.net.csr \
  -keyfile ${SSL_CA_DIR}/private/ca.key \
  -keyform PEM \
  -out ${SSL_CA_DIR}/certs/alm.se.lemche.net.crt \
  -passin "pass:${CA_PASSWORD}"

# Generate new CRL
yes | sudo openssl ca \
  -gencrl \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -keyfile ${SSL_CA_DIR}/private/ca.key \
  -keyform PEM \
  -out ${SSL_CA_DIR}/ca.crl \
  -passin pass:${CA_PASSWORD}

# Copy certificate, and key to OS keystore
sudo cp -f \
  ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.crt \
  /etc/ssl/certs/${CONTROLLER_FQDN}.crt
sudo cp -f \
  ${SSL_CA_DIR}/private/${CONTROLLER_FQDN}.key \
  /etc/ssl/private/${CONTROLLER_FQDN}.key

sudo cp -f \
  ${SSL_CA_DIR}/certs/alm.se.lemche.net.crt \
  /etc/ssl/certs/alm.se.lemche.net.crt
sudo cp -f \
  ${SSL_CA_DIR}/private/alm.se.lemche.net.key \
  /etc/ssl/private/alm.se.lemche.net.key

# Ensure that the ssl-cert group owns the keypair
sudo su -c "chown root:ssl-cert \
  /etc/ssl/certs/*.crt \
  /etc/ssl/private/*.key"

# Restrict access to the keypair
sudo chmod 644 /etc/ssl/certs/*.crt
sudo su -c "chmod 640 /etc/ssl/private/*.key"

# Make the apache runtime user a member of ssl-cert
sudo usermod -a -G ssl-cert www-data

# Add CA certifiate to OS trust store
sudo cp -f \
  ${SSL_CA_DIR}/certs/ca.crt \
  /usr/local/share/ca-certificates/${SSL_CA_NAME}.crt

# Update OS truststore
sudo update-ca-certificates \
  --verbose \
  --fresh

##############################################################################
# Restart apache2 to let it use SSL
##############################################################################
sudo a2enmod ssl
sudo sed -i "s|SSLCertificateFile\s*/etc/ssl/certs/ssl-cert-snakeoil.pem|SSLCertificateFile /etc/ssl/certs/${CONTROLLER_FQDN}.crt|g" /etc/apache2/sites-available/default-ssl.conf
sudo sed -i "s|SSLCertificateKeyFile\s*/etc/ssl/private/ssl-cert-snakeoil.key|SSLCertificateKeyFile /etc/ssl/private/${CONTROLLER_FQDN}.key|g" /etc/apache2/sites-available/default-ssl.conf
sudo a2ensite default-ssl.conf
sudo apachectl configtest
sudo systemctl restart apache2

# Check that apache is using the correct certificate
echo Q | openssl s_client -connect jack.se.lemche.net:443 | openssl x509 -text
