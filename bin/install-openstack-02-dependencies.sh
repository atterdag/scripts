#!/bin/sh

##############################################################################
# Install dependencies
##############################################################################
apt-get --yes install arptables ebtables lvm2 python-pip

##############################################################################
# Install NTP on Controller host
##############################################################################
apt-get --yes install chrony

mv /etc/chrony/chrony.conf /etc/chrony/chrony.conf.org
cat >> /etc/chrony/chrony.conf << EOT
allow ${NETWORK_CIDR}
EOT
systemctl restart chrony
chmod 0644 /etc/chrony/chrony.conf
chown root:root /etc/chrony/chrony.conf

##############################################################################
# Install NTP on Compute host
##############################################################################
apt-get --yes install chrony

mv /etc/chrony/chrony.conf /etc/chrony/chrony.conf.org
cat > /etc/chrony/chrony.conf << EOT
server ${CONTROLLER_IP_ADDRESS}
EOT
systemctl restart chrony
chmod 0644 /etc/chrony/chrony.conf
chown root:root /etc/chrony/chrony.conf

##############################################################################
# Install OpenStack command line tool on Controller host
##############################################################################
apt-get --yes install python-openstackclient

# pip install python-openstackclient
# pip install python-barbicanclient
# pip install python-ceilometerclient
# pip install python-cinderclient
# pip install python-cloudkittyclient
# pip install python-designateclient
# pip install python-fuelclient
# pip install python-glanceclient
# pip install python-gnocchiclient
# pip install python-heatclient
# pip install python-magnumclient
# pip install python-manilaclient
# pip install python-mistralclient
# pip install python-monascaclient
# pip install python-muranoclient
# pip install python-neutronclient
# pip install python-novaclient
# pip install python-saharaclient
# pip install python-senlinclient
# pip install python-swiftclient
# pip install python-troveclient

##############################################################################
# Install Database on Controller host
##############################################################################
apt-get --yes install mysql-server python-pymysql

cat > /etc/mysql/mariadb.conf.d/99-openstack.cnf << EOF
[mysqld]
bind-address = ${CONTROLLER_IP_ADDRESS}

default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
systemctl restart mysql

##############################################################################
# Install Queue Manager on Controller host
##############################################################################
apt-get --yes install rabbitmq-server

rabbitmqctl add_user openstack $RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

##############################################################################
# Install Memcached on Controller
##############################################################################
apt-get --yes install memcached python-memcache

sed -i "s/^-l\s.*$/-l ${CONTROLLER_IP_ADDRESS}/" /etc/memcached.conf
systemctl restart memcached

##############################################################################
# Install Apache on Controller host
##############################################################################
apt-get --yes install apache2

sed -i 's|^ServerTokens|#ServerTokens|' /etc/apache2/conf-available/security.conf
sed -i 's|^#ServerTokens Minimal|ServerTokens Minimal|' /etc/apache2/conf-available/security.conf
sed -i 's|^ServerSignature|#ServerSignature|' /etc/apache2/conf-available/security.conf
sed -i 's|^#ServerSignature Off|ServerSignature Off|' /etc/apache2/conf-available/security.conf
a2enconf security

echo "ServerName ${CONTROLLER_FQDN}" > /etc/apache2/conf-available/servername.conf
a2enconf servername

a2enmod ssl
systemctl reload apache2

##############################################################################
# Install Bind on Controller host
##############################################################################
apt-get install --yes --quiet bind9 bind9utils bind9-doc

rndc-confgen -a -k designate -c /etc/bind/designate.key
chmod 0640 /etc/bind/designate.key
chown bind:bind /etc/bind/designate.key

sed -i 's|^};|\
\tallow-new-zones yes;\
\trequest-ixfr no;\
\tlisten-on port 53 { any; };\
\trecursion no;\
\tallow-query { any; };\
};|' /etc/bind/named.conf.options

cat > /etc/bind/designate.conf << EOF
include "/etc/bind/designate.key";

controls {
  inet 0.0.0.0 port 953
    allow { any; } keys { "designate"; };
};
EOF

cat >> /etc/bind/named.conf.local << EOF
include "/etc/bind/designate.conf";
EOF

systemctl restart bind9

##############################################################################
# Install OpenSSL on Controller host
##############################################################################
apt-get install --yes --quiet openssl

mkdir -p ${SSL_CA_DIR}/{certs,crl,reqs,newcerts,private}
chown -R root:ssl-cert ${SSL_CA_DIR}/private
chmod 0750 ${SSL_CA_DIR}/private
sed 's|./demoCA|${SSL_CA_DIR}|g' /etc/ssl/openssl.cnf > ${SSL_CA_DIR}/openssl.cnf
echo "01" > ${SSL_CA_DIR}/serial
echo "01" > ${SSL_CA_DIR}/crlnumber
touch ${SSL_CA_DIR}/index.txt

cat > ${SSL_CA_DIR}/openssl.cnf << EOF
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
openssl req \
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
openssl req \
  -config <(cat ${SSL_CA_DIR}/openssl.cnf; \
    printf "[SAN]\nsubjectAltName=DNS:${CONTROLLER_FQDN}") \
  -keyout ${SSL_CA_DIR}/private/${CONTROLLER_FQDN}.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_CA_DIR}/reqs/${CONTROLLER_FQDN}.csr \
  -reqexts SAN \
  -sha256 \
  -subj "/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${CONTROLLER_FQDN}" \
  -subject \
  -text

yes | openssl ca \
  -cert ${SSL_CA_DIR}/certs/ca.crt \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -days 365 \
  -in ${SSL_CA_DIR}/reqs/${CONTROLLER_FQDN}.csr \
  -keyfile ${SSL_CA_DIR}/private/ca.key \
  -keyform PEM \
  -out ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.crt \
  -passin pass:${CA_PASSWORD}

# Generate compute node key, and certifiate
openssl req \
  -config <(cat ${SSL_CA_DIR}/openssl.cnf; \
    printf "[SAN]\nsubjectAltName=DNS:${COMPUTE_FQDN}") \
  -keyout ${SSL_CA_DIR}/private/${COMPUTE_FQDN}.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_CA_DIR}/reqs/${COMPUTE_FQDN}.csr \
  -reqexts SAN \
  -sha256 \
  -subj "/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${COMPUTE_FQDN}" \
  -subject \
  -text

yes | openssl ca \
  -cert ${SSL_CA_DIR}/certs/ca.crt \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -days 365 \
  -in ${SSL_CA_DIR}/reqs/${COMPUTE_FQDN}.csr \
  -keyfile ${SSL_CA_DIR}/private/ca.key \
  -keyform PEM \
  -out ${SSL_CA_DIR}/certs/${COMPUTE_FQDN}.crt \
  -passin "pass:${CA_PASSWORD}"

# Generate new CRL
yes | openssl ca \
  -gencrl \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -keyfile ${SSL_CA_DIR}/private/ca.key \
  -keyform PEM \
  -out ${SSL_CA_DIR}/ca.crl \
  -passin pass:${CA_PASSWORD}

# Copy certificate, and key to OS keystore
cp -f \
  ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.crt \
  /etc/ssl/certs/${CONTROLLER_FQDN}.crt

cp -f \
  ${SSL_CA_DIR}/private/${CONTROLLER_FQDN}.key \
  /etc/ssl/private/${CONTROLLER_FQDN}.key

# Ensure that the ssl-cert group owns the keypair
chown root:ssl-cert \
  /etc/ssl/certs/${CONTROLLER_FQDN}.crt \
  /etc/ssl/private/${CONTROLLER_FQDN}.key

# Restrict access to the keypair
chmod 644 /etc/ssl/certs/${CONTROLLER_FQDN}.crt
chmod 640 /etc/ssl/private/${CONTROLLER_FQDN}.key

# Make the apache runtime user a member of ssl-cert
usermod -a -G ssl-cert www-data

# Add CA certifiate to OS trust store
cp -f \
  ${SSL_CA_DIR}/certs/ca.crt \
  /usr/local/share/ca-certificates/${SSL_CA_NAME}.crt

# Update OS truststore
update-ca-certificates \
  --verbose \
  --fresh
