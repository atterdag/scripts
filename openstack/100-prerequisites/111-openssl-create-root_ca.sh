#!/bin/bash

##############################################################################
# Create Root CA key pair
##############################################################################

# sudo rm -fr /var/lib/ssl/*

# Create root CA
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
keyUsage                       = critical, digitalSignature, keyEncipherment
extendedKeyUsage               = serverAuth
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

# Add CA certifiate to OS trust store
sudo openssl x509 \
  -in ${SSL_BASE_DIR}/${SSL_ROOT_CA_STRICT_NAME}/certs/${SSL_ROOT_CA_STRICT_NAME}.crt \
  -out /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt

# Update OS truststore
sudo update-ca-certificates \
  --verbose \
  --fresh
