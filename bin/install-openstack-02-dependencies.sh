#!/bin/sh

##############################################################################
# Get package listing
##############################################################################
dpkg -l | grep ^ii | awk '{print $2}' > os_installed_packages.txt

##############################################################################
# Set default shell to bash
##############################################################################
echo 'dash dash/sh boolean false' | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

##############################################################################
# Ensure that controller FQDN is present in /etc/hosts
##############################################################################
if ! grep $CONTROLLER_FQDN /etc/hosts > /dev/null; then
  echo -e "$CONTROLLER_IP_ADDRESS\t$CONTROLLER_FQDN\t$(echo $CONTROLLER_FQDN | awk -F'.' '{print $1}')" | sudo tee -a /etc/hosts
fi

##############################################################################
# Install dependencies that are not automatically installed
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
\t// recursion no;\
\tallow-query { any; };\
\tforward first;\
\tforwarders { 1.1.1.1; 1.0.0.1; };\
\tallow-query-cache { any; };\
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
sudo apt-get install --yes --quiet \
  ca-certificates \
  openssl \
  ssl-cert


#
# Create root CA
#
sudo mkdir -p ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/{certs,crl,newcerts,private,reqs}
sudo chown -R root:ssl-cert ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private
sudo chmod 0750 ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private
echo "01" | sudo tee ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/serial
echo "01" | sudo tee ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/crlnumber
sudo touch ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/index.{txt,txt.attr}

# Generate random numbers
sudo openssl rand \
  -out ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private/.rnd \
  4096

cat << EOF | sudo tee ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/openssl.cnf
HOME                           = ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}
oid_section                    = new_oids

[ ca ]
default_ca                     = CA_default

[ CA_default ]
# General locations
dir                            = ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}
certs                          = \$dir/certs
database                       = \$dir/index.txt
new_certs_dir                  = \$dir/newcerts
RANDFILE                       = \$dir/private/.rnd
serial                         = \$dir/serial

# Root CA keypair
certificate                    = \$dir/certs/${SSL_ROOT_CA_STRICT_NAME}.crt
private_key                    = \$dir/private/${SSL_ROOT_CA_STRICT_NAME}.key

# CRL specific
crl                            = \$dir/${SSL_ROOT_CA_STRICT_NAME}.crl
crl_dir                        = \$dir/crl
crl_extensions                 = crl_ext
crlnumber                      = \$dir/crlnumber
default_crl_days               = 30

# Set certifiate defaults
cert_opt                       = ca_default
copy_extensions                = copy
default_days                   = 375
default_md                     = sha256
name_opt                       = ca_default
policy                         = policy_match
preserve                       = no
x509_extensions                = server_cert

# Used for non CA certificate
[ policy_match ]
commonName                     = supplied
countryName                    = match
emailAddress                   = optional
organizationalUnitName         = optional
organizationName               = match
stateOrProvinceName            = match

# Loose policy used for CA certificate
[ policy_anything ]
commonName                     = supplied
countryName                    = optional
emailAddress                   = optional
localityName                   = optional
organizationalUnitName         = optional
organizationName               = optional
stateOrProvinceName            = optional

[ req ]
default_bits                   = 2048
default_md                     = sha256
distinguished_name             = req_distinguished_name
string_mask                    = pkix
x509_extensions                = v3_root_ca

[ req_distinguished_name ]
commonName                     = Common Name (e.g. server FQDN or YOUR name)
countryName                    = Country Name (2 letter code)
emailAddress                   = Email Address
localityName                   = Locality Name (eg, city)
0.organizationName             = Organization Name (eg, company)
organizationalUnitName         = Organizational Unit Name (eg, section)
stateOrProvinceName            = State or Province Name (full name)

# Max/min values for values
commonName_max                 = 64
countryName_max                = 2
countryName_min                = 2
emailAddress_max               = 256

# Set some default values
countryName_default            = $SSL_COUNTRY_NAME
emailAddress_default           = $SSL_CA_EMAIL
0.organizationName_default     = $SSL_ORGANIZATION_NAME
organizationalUnitName_default = $SSL_ORGANIZATIONAL_UNIT_NAME
stateOrProvinceName_default    = $SSL_STATE

[ crl_distpoints ]
URI.1                          = ${SSL_BASE_URL}/ca.crl

# Extension for root CA certifiate
[ v3_root_ca ]
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid:always, issuer:always
basicConstraints               = critical, CA:true
keyUsage                       = critical, digitalSignature, cRLSign, keyCertSign
crlDistributionPoints          = @crl_distpoints

# Extension for intermediate CA certifiate
[ v3_intermediate_ca ]
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid:always, issuer:always
basicConstraints               = critical, CA:true, pathlen:0
keyUsage                       = critical, digitalSignature, cRLSign, keyCertSign
crlDistributionPoints          = @crl_distpoints

# Extension for Client/User certificates
[ usr_cert ]
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid, issuer:always
basicConstraints               = CA:FALSE
keyUsage                       = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage               = clientAuth, emailProtection
nsCertType                     = client, email
nsComment                      = "OpenSSL Generated Client Certificate"
crlDistributionPoints          = @crl_distpoints
authorityInfoAccess            = OCSP;URI:${SSL_BASE_URL}

# Extension for Server certificates
[ server_cert ]
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid, issuer:always
basicConstraints               = CA:FALSE
keyUsage                       = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage               = clientAuth, emailProtection
nsCertType                     = server
nsComment                      = "OpenSSL Generated Server Certificate"
crlDistributionPoints          = @crl_distpoints
authorityInfoAccess            = OCSP;URI:${SSL_BASE_URL}

# Extension for CRLs
[ crl_ext ]
issuerAltName                  = issuer:copy
authorityKeyIdentifier         = keyid:always

# Extension for OCSP signing certificates
[ ocsp ]
authorityKeyIdentifier         = keyid, issuer:always
basicConstraints               = CA:FALSE
extendedKeyUsage               = critical, OCSPSigning
keyUsage                       = critical, digitalSignature
subjectKeyIdentifier           = hash

# Adds timestamp certifiate extensions
[ new_oids ]
tsa_policy1                    = 1.2.3.4.1
tsa_policy2                    = 1.2.3.4.5.6
tsa_policy3                    = 1.2.3.4.5.7

[ tsa ]
default_tsa                    = tsa_config1

[ tsa_config1 ]
dir                            = ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}
accuracy                       = secs:1, millisecs:500, microsecs:100
certs                          = \$dir/cacert.pem
clock_precision_digits         = 0
crypto_device                  = builtin
default_policy                 = tsa_policy1
digests                        = sha1, sha256, sha384, sha512
ess_cert_id_chain              = no
ordering                       = yes
other_policies                 = tsa_policy2, tsa_policy3
serial                         = \$dir/tsaserial
signer_cert                    = \$dir/tsacert.pem
signer_digest                  = sha256
signer_key                     = \$dir/private/tsakey.pem
tsa_name                       = yes
EOF

# Generate new CA key
sudo openssl genrsa \
  -aes256 \
  -out ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private/${SSL_ROOT_CA_STRICT_NAME}.key \
  -passout pass:${CA_PASSWORD} \
  4096

# Generate new CA certifiate
sudo openssl req \
  -batch \
  -config ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/openssl.cnf \
  -days 10950 \
  -extensions "v3_root_ca" \
  -key ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private/${SSL_ROOT_CA_STRICT_NAME}.key \
  -keyform PEM \
  -new \
  -out ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
  -outform PEM \
  -passin pass:${CA_PASSWORD} \
  -passout pass:${CA_PASSWORD} \
  -sha512 \
  -subj "/C=${SSL_COUNTRY_NAME}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${SSL_ROOT_CA_COMMON_NAME}" \
  -subject \
  -text \
  -verbose \
  -utf8 \
  -x509

# ... out of curiosity
sudo openssl x509 \
  -x509toreq \
  -passin pass:${CA_PASSWORD} \
  -signkey ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private/${SSL_ROOT_CA_STRICT_NAME}.key \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
  -out ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/reqs/${SSL_ROOT_CA_STRICT_NAME}.csr

#
# Create intermediate CA 1
#
sudo mkdir -p ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/{certs,crl,newcerts,private,reqs}
sudo chown -R root:ssl-cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private
sudo chmod 0750 ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private
echo "01" | sudo tee ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/serial
echo "01" | sudo tee ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/crlnumber
sudo touch ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/index.{txt,txt.attr}

# Generate random numbers
sudo openssl rand \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/.rnd \
  4096

cat << EOF | sudo tee ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf
HOME                           = ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}
oid_section                    = new_oids

[ ca ]
default_ca                     = CA_default

[ CA_default ]
# General locations
dir                            = ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}
certs                          = \$dir/certs
database                       = \$dir/index.txt
new_certs_dir                  = \$dir/newcerts
RANDFILE                       = \$dir/private/.rnd
serial                         = \$dir/serial

# Root CA keypair
certificate                    = \$dir/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt
private_key                    = \$dir/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key

# CRL specific
crl                            = \$dir/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crl
crl_dir                        = \$dir/crl
crl_extensions                 = crl_ext
crlnumber                      = \$dir/crlnumber
default_crl_days               = 30

# Set certifiate defaults
cert_opt                       = ca_default
copy_extensions                = copy
default_days                   = 375
default_md                     = sha256
name_opt                       = ca_default
policy                         = policy_anything
preserve                       = no
x509_extensions                = server_cert

# Used for non CA certificate
[ policy_match ]
commonName                     = supplied
countryName                    = match
emailAddress                   = optional
organizationalUnitName         = optional
organizationName               = match
stateOrProvinceName            = match

# Loose policy used for CA certificate
[ policy_anything ]
commonName                     = supplied
countryName                    = optional
emailAddress                   = optional
localityName                   = optional
organizationalUnitName         = optional
organizationName               = optional
stateOrProvinceName            = optional

[ req ]
default_bits                   = 2048
default_md                     = sha256
distinguished_name             = req_distinguished_name
string_mask                    = pkix
x509_extensions                = v3_root_ca

[ req_distinguished_name ]
commonName                     = Common Name (e.g. server FQDN or YOUR name)
countryName                    = Country Name (2 letter code)
emailAddress                   = Email Address
localityName                   = Locality Name (eg, city)
0.organizationName             = Organization Name (eg, company)
organizationalUnitName         = Organizational Unit Name (eg, section)
stateOrProvinceName            = State or Province Name (full name)

# Max/min values for values
commonName_max                 = 64
countryName_max                = 2
countryName_min                = 2
emailAddress_max               = 256

# Set some default values
countryName_default            = $SSL_COUNTRY_NAME
emailAddress_default           = $SSL_CA_EMAIL
0.organizationName_default     = $SSL_ORGANIZATION_NAME
organizationalUnitName_default = $SSL_ORGANIZATIONAL_UNIT_NAME
stateOrProvinceName_default    = $SSL_STATE

[ crl_distpoints ]
URI.1                          = ${SSL_BASE_URL}/ca.crl

# Extension for root CA certifiate
[ v3_root_ca ]
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid:always, issuer:always
basicConstraints               = critical, CA:true
keyUsage                       = critical, digitalSignature, cRLSign, keyCertSign
crlDistributionPoints          = @crl_distpoints

# Extension for intermediate CA certifiate
[ v3_intermediate_ca ]
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid:always, issuer:always
basicConstraints               = critical, CA:true, pathlen:0
keyUsage                       = critical, digitalSignature, cRLSign, keyCertSign
crlDistributionPoints          = @crl_distpoints

# Extension for Client/User certificates
[ usr_cert ]
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid, issuer:always
basicConstraints               = CA:FALSE
keyUsage                       = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage               = clientAuth, emailProtection
nsCertType                     = client, email
nsComment                      = "OpenSSL Generated Client Certificate"
crlDistributionPoints          = @crl_distpoints
authorityInfoAccess            = OCSP;URI:${SSL_BASE_URL}

# Extension for Server certificates
[ server_cert ]
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid, issuer:always
basicConstraints               = CA:FALSE
keyUsage                       = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage               = clientAuth, emailProtection
nsCertType                     = server
nsComment                      = "OpenSSL Generated Server Certificate"
crlDistributionPoints          = @crl_distpoints
authorityInfoAccess            = OCSP;URI:${SSL_BASE_URL}

# Extension for CRLs
[ crl_ext ]
issuerAltName                  = issuer:copy
authorityKeyIdentifier         = keyid:always

# Extension for OCSP signing certificates
[ ocsp ]
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid, issuer:always
basicConstraints               = CA:FALSE
extendedKeyUsage               = critical, OCSPSigning
keyUsage                       = critical, digitalSignature

# Adds timestamp certifiate extensions
[ new_oids ]
tsa_policy1                    = 1.2.3.4.1
tsa_policy2                    = 1.2.3.4.5.6
tsa_policy3                    = 1.2.3.4.5.7

[ tsa ]
default_tsa                    = tsa_config1

[ tsa_config1 ]
dir                            = ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}
accuracy                       = secs:1, millisecs:500, microsecs:100
certs                          = \$dir/cacert.pem
clock_precision_digits         = 0
crypto_device                  = builtin
default_policy                 = tsa_policy1
digests                        = sha1, sha256, sha384, sha512
ess_cert_id_chain              = no
ordering                       = yes
other_policies                 = tsa_policy2, tsa_policy3
serial                         = \$dir/tsaserial
signer_cert                    = \$dir/tsacert.pem
signer_digest                  = sha256
signer_key                     = \$dir/private/tsakey.pem
tsa_name                       = yes
EOF

# Generate new intermediate CA key
sudo openssl genrsa \
  -aes256 \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -passout pass:${CA_PASSWORD} \
  4096

# Generate new intermediate CA request
sudo -E openssl req \
  -batch \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -key ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -new \
  -nodes \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.csr \
  -passin pass:${CA_PASSWORD} \
  -sha256 \
  -subj "/C=${SSL_COUNTRY_NAME}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME}" \
  -subject \
  -text \
  -utf8

# Copy intermediate CA certificate request to root CA
sudo cp ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.csr \
  ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.csr

# Generate new intermediate CA certifiate
sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/openssl.cnf \
  -days 3650 \
  -extensions v3_intermediate_ca \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private/${SSL_ROOT_CA_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  -passin pass:${CA_PASSWORD} \
  -policy policy_anything

# Copy intermediate CA certificate to intermediate CA
sudo cp ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt

# Generate new OCSP key
sudo openssl genrsa \
  -aes256 \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.key \
  -passout pass:${CA_PASSWORD} \
  4096

# Generate OCSP certificate request
sudo openssl req \
  -batch \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -key ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.key \
  -new \
  -nodes \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.csr \
  -passin pass:${CA_PASSWORD} \
  -sha256 \
  -subj "/C=${SSL_COUNTRY_NAME}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${SSL_INTERMEDIATE_OCSP_ONE_FQDN}" \
  -subject \
  -text \
  -utf8

# Generate OCSP certifiate
sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -days 375 \
  -extensions ocsp \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.crt \
  -md sha256 \
  -passin pass:${CA_PASSWORD}

# Generate controller node key, and certifiate
sudo su -c "openssl req \
  -batch \
  -config <(cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf; \
    printf \"[SAN]\nsubjectAltName=DNS:${CONTROLLER_FQDN}\") \
  -keyout ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${CONTROLLER_FQDN}.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${CONTROLLER_FQDN}.csr \
  -reqexts SAN \
  -sha256 \
  -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${CONTROLLER_FQDN}\" \
  -subject \
  -utf8"

sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -days 365 \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${CONTROLLER_FQDN}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CONTROLLER_FQDN}.crt \
  -passin pass:${CA_PASSWORD}

# Copy controller certificate, and key to OS keystore
sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CONTROLLER_FQDN}.crt \
  -out /etc/ssl/certs/${CONTROLLER_FQDN}.crt
sudo openssl rsa \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${CONTROLLER_FQDN}.key \
  -out /etc/ssl/private/${CONTROLLER_FQDN}.key

# sudo openssl ca \
#   -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
#   -revoke ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.crt \
#   -passin "pass:${CA_PASSWORD}"

# DON'T RUN IF CONTROLLER IS COMPUTE NODE
# Generate compute node key, and certifiate
sudo su -c "openssl req \
  -batch \
  -config <(cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf; \
    printf \"[SAN]\nsubjectAltName=DNS:${COMPUTE_FQDN}\") \
  -keyout ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${COMPUTE_FQDN}.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${COMPUTE_FQDN}.csr \
  -reqexts SAN \
  -sha256 \
  -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${COMPUTE_FQDN}\" \
  -subject \
  -utf8"

sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -days 365 \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${COMPUTE_FQDN}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${COMPUTE_FQDN}.crt \
  -passin pass:${CA_PASSWORD}

# Copy compute certificate, and key to OS keystore
sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${COMPUTE_FQDN}.crt \
  -out /etc/ssl/certs/${COMPUTE_FQDN}.crt
sudo openssl rsa \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${COMPUTE_FQDN}.key \
  -out /etc/ssl/private/${COMPUTE_FQDN}.key

# Generate ALM key, and certifiate
sudo su -c "openssl req \
  -batch \
  -config <(cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf; \
    printf \"[SAN]\nsubjectAltName=DNS:alm.se.lemche.net,DNS:joxit.se.lemche.net,DNS:registry.se.lemche.net,DNS:gogs.se.lemche.net,DNS:awx.se.lemche.net\") \
  -keyout ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/alm.se.lemche.net.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/alm.se.lemche.net.csr \
  -reqexts SAN \
  -sha256 \
  -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=alm.se.lemche.net\" \
  -subject \
  -utf8"

sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -days 365 \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/alm.se.lemche.net.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/alm.se.lemche.net.crt \
  -passin "pass:${CA_PASSWORD}"

# Copy ALM certificate, and key to OS keystore
sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/alm.se.lemche.net.crt \
  -out /etc/ssl/certs/alm.se.lemche.net.crt
sudo openssl rsa \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/alm.se.lemche.net.key \
  -out /etc/ssl/private/alm.se.lemche.net.key

# Generate new CRL
sudo openssl ca \
  -batch \
  -gencrl \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/ca.crl \
  -passin pass:${CA_PASSWORD}

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
sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
  -out /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt
sudo openssl x509 \
  -in  ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  -out /usr/local/share/ca-certificates/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt

# Update OS truststore
sudo update-ca-certificates \
  --verbose \
  --fresh

# Create CA chain
openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
| sudo tee ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt
openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
| sudo tee -a ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt

# Test OCSP
echo ${CA_PASSWORD}
sudo openssl ocsp \
  -index ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/index.txt \
  -port 2560 \
  -rsigner ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.crt \
  -rkey ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.key \
  -CA ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
  -text \
  -nrequest 1 \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.log

# Test in another terminal
sudo openssl ocsp \
  -CAfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
  -url http://127.0.0.1:2560 \
  -resp_text \
  -issuer ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_OCSP_ONE_FQDN}.crt \
  -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CONTROLLER_FQDN}.crt

# Convert PKCS#12 database with the controller keypair
sudo openssl pkcs12 \
  -caname "${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME}" \
  -caname "${SSL_ROOT_CA_COMMON_NAME}" \
  -certfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
  -export \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CONTROLLER_FQDN}.crt \
  -inkey ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${CONTROLLER_FQDN}.key \
  -name ${CONTROLLER_FQDN} \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CONTROLLER_FQDN}.p12 \
  -passout "pass:${CONTROLLER_KEYSTORE_PASS}"

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

sudo apachectl configtest
sudo systemctl restart apache2

# Check that apache is using the correct certificate
echo Q | openssl s_client -connect ${CONTROLLER_FQDN}:443 | openssl x509 -text

##############################################################################
# Install 389 Directory Server
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install 389-ds

cat << EOF | sudo tee /etc/sysctl.d/99-389-ds.conf
net.ipv4.tcp_keepalive_time = 300
net.ipv4.ip_local_port_range = 1024 65000
fs.file-max = 64000
EOF
sudo sysctl --load=/etc/sysctl.d/99-389-ds.conf

cat << EOF | sudo tee /etc/security/limits.d/389-ds.conf
*             -       nofile          8192
EOF

cat << EOF | sudo tee /var/lib/openstack/389-ds-setup.inf
[General]
FullMachineName=${CONTROLLER_FQDN}
SuiteSpotUserID=dirsrv
SuiteSpotGroup=dirsrv
AdminDomain=${DNS_DOMAIN}
ConfigDirectoryAdminID=admin
ConfigDirectoryAdminPwd=${DS_ADMIN_PASS}
ConfigDirectoryLdapURL=ldap://${CONTROLLER_FQDN}:389/o=NetscapeRoot

[slapd]
SlapdConfigForMC=Yes
UseExistingMC=0
ServerPort=389
ServerIdentifier=default
Suffix=${DS_SUFFIX}
RootDN=cn=Directory Manager
RootDNPwd=${DS_ROOT_PASS}
AddSampleEntries=Yes

[admin]
Port=9830
ServerIpAddress=${CONTROLLER_IP_ADDRESS}
ServerAdminID=admin
ServerAdminPwd=${DS_ADMIN_PASS}
EOF
sudo setup-ds-admin \
  --silent \
  --file=/var/lib/openstack/389-ds-setup.inf

sudo certutil \
  -A \
  -d /etc/dirsrv/slapd-default/ \
  -n "${SSL_ROOT_CA_COMMON_NAME}" \
  -t "C,," \
  -i /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt
sudo certutil \
  -A \
  -d /etc/dirsrv/slapd-default/ \
  -n "${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME}" \
  -t "C,," \
  -i /usr/local/share/ca-certificates/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt
sudo pk12util \
  -i ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${CONTROLLER_FQDN}.p12 \
  -d /etc/dirsrv/slapd-default/ \
  -n ${CONTROLLER_FQDN} \
  -K ${CONTROLLER_KEYSTORE_PASS} \
  -W ${CONTROLLER_KEYSTORE_PASS}
sudo certutil \
  -d /etc/dirsrv/slapd-default/ \
  -L

echo "Internal (Software) Token:${CONTROLLER_KEYSTORE_PASS}" \
| sudo tee /etc/dirsrv/slapd-default/pin.txt

cat << EOF | sudo tee /var/lib/openstack/389-ds-enable-security.ldif
dn: cn=config
changetype: modify
replace: nsslapd-security
nsslapd-security: on
EOF

sudo ldapmodify \
  -H ldap://${CONTROLLER_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -x \
  -f /var/lib/openstack/389-ds-enable-security.ldif

cat << EOF | sudo tee /var/lib/openstack/389-ds-configure-security.ldif
dn: cn=encryption,cn=config
changetype: modify
replace: nsSSLSessionTimeout
nsSSLSessionTimeout: 0
-
replace: nsSSLClientAuth
nsSSLClientAuth: off
-
replace: nsSSL3
nsSSL3: off
-
replace: nsSSL2
nsSSL2: off
EOF

sudo ldapmodify \
  -H ldap://${CONTROLLER_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -x \
  -f /var/lib/openstack/389-ds-configure-security.ldif

cat << EOF | sudo tee /var/lib/openstack/389-ds-add-rsa.ldif
dn: cn=RSA,cn=encryption,cn=config
changetype: add
objectClass: nsEncryptionModule
objectClass: top
nsSSLActivation: on
nsSSLToken: internal (software)
nsSSLPersonalitySSL: ${CONTROLLER_FQDN}
cn: RSA
EOF

sudo ldapmodify \
  -H ldap://${CONTROLLER_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -x \
  -f /var/lib/openstack/389-ds-add-rsa.ldif

sudo systemctl enable dirsrv@default.service
sudo systemctl restart dirsrv@default.service

# Check encryption configuration
ldapsearch \
  -H ldap://${CONTROLLER_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -Z \
  -b 'cn=encryption,cn=config' \
  -x

if ! sudo grep "sslVersionMin: TLS1.1" /etc/dirsrv/admin-serv/adm.conf > /dev/null; then
  echo "sslVersionMin: TLS1.1" | sudo tee -a /etc/dirsrv/admin-serv/adm.conf
fi
if ! sudo grep "sslVersionMax: TLS1.2" /etc/dirsrv/admin-serv/adm.conf > /dev/null; then
  echo "sslVersionMax: TLS1.2" | sudo tee -a /etc/dirsrv/admin-serv/adm.conf
fi

##############################################################################
# Install DogTag
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install \
  pki-ca \
  pki-kra \
  liboscache-java \
  libstax-java

cat << EOF | sudo tee /var/lib/openstack/dogtag-step1.cfg
[DEFAULT]
pki_admin_password = ${PKI_ADMIN_PASSWORD}
pki_ajp_port = 8009
pki_backup_password = ${PKI_BACKUP_PASSWORD}
pki_client_database_password = ${PKI_CLIENT_DATABASE_PASSWORD}
# pki_client_pin = XXXXXXXX
pki_client_pkcs12_password = ${PKI_CLIENT_PKCS12_PASSWORD}
pki_clone_pkcs12_password = ${PKI_CLONE_PKCS12_PASSWORD}
pki_ds_bind_dn = cn=Directory Manager
pki_ds_hostname = ${CONTROLLER_FQDN}
pki_ds_ldap_port = 389
pki_ds_ldaps_port = 636
pki_ds_password = ${DS_ROOT_PASS}
pki_ds_secure_connection = True
pki_ds_secure_connection_ca_pem_file = /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt
# pki_external_pkcs12_password = XXXXXXXX
pki_http_port = 8080
pki_https_port = 8443
pki_instance_name = ${SSL_PKI_INSTANCE_NAME}
# pki_one_time_pin = XXXXXXXX
# pki_pin = XXXXXXXX
pki_pkcs12_password = ${CA_PASSWORD}
pki_replication_password = ${PKI_REPLICATION_PASSWORD}
pki_security_domain_hostname = ${CONTROLLER_FQDN}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_password = ${PKI_SECURITY_DOMAIN_PASSWORD}
pki_server_database_password = ${PKI_SERVER_DATABASE_PASSWORD}
# pki_server_pkcs12_password = XXXXXXXX
pki_sslserver_key_algorithm=SHA256withRSA
pki_sslserver_key_size=2048
pki_sslserver_key_type=rsa
pki_sslserver_nickname = sslserver/${CONTROLLER_FQDN}
pki_sslserver_subject_dn=cn=${CONTROLLER_FQDN},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_subsystem_key_algorithm=SHA256withRSA
pki_subsystem_key_size=2048
pki_subsystem_key_type=rsa
pki_subsystem_nickname = subsystem/${CONTROLLER_FQDN}
pki_subsystem_subject_dn=cn=Subsystem Certificate,ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_token_password = ${PKI_TOKEN_PASSWORD}
pki_tomcat_server_port = 8005

[CA]
pki_admin_email = caadmin@${DNS_DOMAIN}
pki_admin_name = caadmin
pki_admin_nickname = PKI CA Administrator
pki_admin_uid = caadmin
pki_audit_signing_nickname=${SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME}
pki_ca_signing_csr_path = /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.csr
pki_ca_signing_key_algorithm = SHA256withRSA
pki_ca_signing_key_size = 4096
pki_ca_signing_key_type = rsa
pki_ca_signing_nickname = ${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME}
pki_ca_signing_signing_algorithm = SHA256withRSA
pki_ca_signing_subject_dn = cn=${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_client_database_purge = False
pki_ds_base_dn = dc=ca,dc=pki,${DS_SUFFIX}
pki_ds_database = ca
pki_external = True
pki_external_step_two = False
pki_ocsp_signing_key_algorithm=SHA256withRSA
pki_ocsp_signing_key_size=2048
pki_ocsp_signing_key_type=rsa
pki_ocsp_signing_nickname = ${SSL_INTERMEDIATE_OCSP_TWO_FQDN}
pki_ocsp_signing_signing_algorithm=SHA256withRSA
pki_ocsp_signing_subject_dn=cn=${SSL_INTERMEDIATE_OCSP_TWO_FQDN},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_user = caadmin

EOF
sudo pkispawn \
  -s CA \
  -f /var/lib/openstack/dogtag-step1.cfg

sudo cp \
  -f \
  /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.csr \
  ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.csr

sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/openssl.cnf \
  -days 3650 \
  -extensions v3_intermediate_ca \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/reqs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/private/${SSL_ROOT_CA_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
  -passin pass:${CA_PASSWORD} \
  -policy policy_anything

sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
  -out /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/${SSL_ROOT_CA_STRICT_NAME}.crt
sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
  -out /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.crt

# Update OS truststore
sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt \
  -out /usr/local/share/ca-certificates/${SSL_INTERMEDIATE_CA_TWO_STRICT_NAME}.crt
sudo update-ca-certificates \
  --verbose \
  --fresh

# sudo certutil \
#   -A \
#   -d /etc/pki/${SSL_PKI_INSTANCE_NAME}/alias/ \
#   -n "${SSL_ROOT_CA_COMMON_NAME}" \
#   -t "C,," \
#   -i /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt

cat << EOF | sudo tee /var/lib/openstack/dogtag-step2.cfg
[DEFAULT]
pki_admin_password = ${PKI_ADMIN_PASSWORD}
pki_ajp_port = 8009
pki_backup_password = ${PKI_BACKUP_PASSWORD}
pki_client_database_password = ${PKI_CLIENT_DATABASE_PASSWORD}
# pki_client_pin = XXXXXXXX
pki_client_pkcs12_password = ${PKI_CLIENT_PKCS12_PASSWORD}
pki_clone_pkcs12_password = ${PKI_CLONE_PKCS12_PASSWORD}
pki_ds_bind_dn = cn=Directory Manager
pki_ds_hostname = ${CONTROLLER_FQDN}
pki_ds_ldap_port = 389
pki_ds_ldaps_port = 636
pki_ds_password = ${DS_ROOT_PASS}
pki_ds_secure_connection = True
pki_ds_secure_connection_ca_pem_file = /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt
# pki_external_pkcs12_password = XXXXXXXX
pki_http_port = 8080
pki_https_port = 8443
pki_instance_name = ${SSL_PKI_INSTANCE_NAME}
# pki_one_time_pin = XXXXXXXX
# pki_pin = XXXXXXXX
pki_pkcs12_password = ${CA_PASSWORD}
pki_replication_password = ${PKI_REPLICATION_PASSWORD}
pki_security_domain_hostname = ${CONTROLLER_FQDN}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_password = ${PKI_SECURITY_DOMAIN_PASSWORD}
pki_server_database_password = ${PKI_SERVER_DATABASE_PASSWORD}
# pki_server_pkcs12_password = XXXXXXXX
pki_sslserver_key_algorithm=SHA256withRSA
pki_sslserver_key_size=2048
pki_sslserver_key_type=rsa
pki_sslserver_nickname = sslserver/${CONTROLLER_FQDN}
pki_sslserver_subject_dn=cn=${CONTROLLER_FQDN},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_subsystem_key_algorithm=SHA256withRSA
pki_subsystem_key_size=2048
pki_subsystem_key_type=rsa
pki_subsystem_nickname = subsystem/${CONTROLLER_FQDN}
pki_subsystem_subject_dn=cn=Subsystem Certificate,ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_token_password = ${PKI_TOKEN_PASSWORD}
pki_tomcat_server_port = 8005

[CA]
pki_admin_email = caadmin@${DNS_DOMAIN}
pki_admin_name = caadmin
pki_admin_nickname = PKI CA Administrator
pki_admin_uid = caadmin
pki_audit_signing_nickname=${SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME}
pki_ca_signing_cert_path = /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.crt
pki_ca_signing_csr_path = /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.csr
pki_ca_signing_key_algorithm = SHA256withRSA
pki_ca_signing_key_size = 4096
pki_ca_signing_key_type = rsa
pki_ca_signing_nickname = ${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME}
pki_ca_signing_signing_algorithm = SHA256withRSA
pki_ca_signing_subject_dn = cn=${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_cert_chain_nickname = ${SSL_ROOT_CA_COMMON_NAME}
pki_cert_chain_path = /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/${SSL_ROOT_CA_STRICT_NAME}.crt
pki_client_database_purge = False
pki_ds_base_dn = dc=ca,dc=pki,${DS_SUFFIX}
pki_ds_database = ca
pki_external = True
pki_external_step_two = True
pki_ocsp_signing_key_algorithm=SHA256withRSA
pki_ocsp_signing_key_size=2048
pki_ocsp_signing_key_type=rsa
pki_ocsp_signing_nickname = ${SSL_INTERMEDIATE_OCSP_TWO_FQDN}
pki_ocsp_signing_signing_algorithm=SHA256withRSA
pki_ocsp_signing_subject_dn=cn=${SSL_INTERMEDIATE_OCSP_TWO_FQDN},ou=${SSL_ORGANIZATIONAL_UNIT_NAME},o=${SSL_ORGANIZATION_NAME},c=${SSL_COUNTRY_NAME}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_user = caadmin
EOF
sudo pkispawn \
  -s CA \
  -f /var/lib/openstack/dogtag-step2.cfg

sudo certutil \
  -L \
  -d /etc/pki/${SSL_PKI_INSTANCE_NAME}/alias
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-init
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-cert-import \
  --ca-cert /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/${SSL_ROOT_CA_STRICT_NAME}.crt
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-cert-import \
  "${SSL_INTERMEDIATE_CA_TWO_COMMON_NAME}" \
  --ca-cert /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_signing.crt
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  client-cert-import \
  --pkcs12 /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca_admin_cert.p12 \
  --pkcs12-password-file /root/.dogtag/${SSL_PKI_INSTANCE_NAME}/ca/pkcs12_password.conf
sudo pki \
  -c $PKI_CLIENT_DATABASE_PASSWORD \
  -n caadmin ca-user-show caadmin

cat << EOF | sudo tee /var/lib/openstack/dogtag-kra.cfg
[DEFAULT]
pki_admin_password = ${PKI_ADMIN_PASSWORD}
pki_backup_password = ${PKI_BACKUP_PASSWORD}
pki_client_database_password = ${PKI_CLIENT_DATABASE_PASSWORD}
pki_client_pkcs12_password = ${PKI_CLIENT_PKCS12_PASSWORD}
pki_clone_pkcs12_password = ${PKI_CLONE_PKCS12_PASSWORD}
pki_ds_bind_dn = cn=Directory Manager
pki_ds_hostname = ${CONTROLLER_FQDN}
pki_ds_ldap_port = 389
pki_ds_ldaps_port = 636
pki_ds_password = ${DS_ROOT_PASS}
pki_ds_remove_data = True
pki_ds_secure_connection_ca_pem_file = /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt
pki_ds_secure_connection = True
pki_http_port = 8080
pki_https_port = 8443
pki_instance_name = pki-tomcat
pki_replication_password = ${PKI_REPLICATION_PASSWORD}
pki_security_domain_hostname = ${CONTROLLER_FQDN}
pki_security_domain_name = ${SSL_ORGANIZATION_NAME}
pki_security_domain_password = ${PKI_SECURITY_DOMAIN_PASSWORD}
pki_security_domain_user = caadmin
pki_server_database_password = ${PKI_SERVER_DATABASE_PASSWORD}
pki_token_password = ${PKI_TOKEN_PASSWORD}

[Tomcat]
pki_ajp_port = 8009
pki_tomcat_server_port = 8005

[KRA]
pki_admin_cert_file=/root/.dogtag/pki-tomcat/ca_admin.cert
pki_admin_email=kraadmin@${DNS_DOMAIN}
pki_admin_name=kraadmin
pki_admin_nickname=PKI KRA Administrator
pki_admin_uid=kraadmin
pki_client_database_purge=False
pki_ds_base_dn=dc=kra,dc=pki,${DS_SUFFIX}
pki_ds_database=kra
EOF
sudo pkispawn -s KRA -f /var/lib/openstack/dogtag-kra.cfg

##############################################################################
# Install rng-tools to improve the quality (entropy) of the randomness
##############################################################################
sudo apt --yes install rng-tools
sudo sed -i 's|#HRNGDEVICE=/dev/null|#HRNGDEVICE=/dev/null\nHRNGDEVICE=/dev/urandom|' /etc/default/rng-tools
sudo systemctl restart rng-tools

##############################################################################
# Install Kerberos Master
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt --yes install krb5-kdc krb5-admin-server
cat << EOF | sudo tee /etc/krb5.conf
[libdefaults]
        default_realm = SE.LEMCHE.NET
        kdc_timesync = 1
        ccache_type = 4
        forwardable = true
        proxiable = true
        fcc-mit-ticketflags = true

[realms]
        SE.LEMCHE.NET = {
                kdc = jack.se.lemche.net
                admin_server = jack.se.lemche.net
        }

[domain_realm]
        .se.lemche.net = SE.LEMCHE.NET
        se.lemche.net = SE.LEMCHE.NET
EOF

sudo kdb5_util -P ${KERBEROS_MASTER_SECRET} create -s
sudo systemctl restart \
  krb5-kdc \
  krb5-admin-server
cat << EOF | sudo tee /etc/krb5kdc/kadm5.acl
# This file Is the access control list for krb5 administration.
# When this file is edited run service krb5-admin-server restart to activate
# One common way to set up Kerberos administration is to allow any principal
# ending in /admin  is given full administrative rights.
# To enable this, uncomment the following line:
*/admin *
EOF

##############################################################################
# Install FreeIPA
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install freeipa-server

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
# Enable the OpenStack repository
##############################################################################
sudo apt-get --yes install software-properties-common
sudo add-apt-repository --yes cloud-archive:rocky
sudo apt-get update
sudo apt-get --yes dist-upgrade

##############################################################################
# Install OpenStack command line tool on Controller host
##############################################################################
sudo apt-get --yes install python-openstackclient python-oslo.log
