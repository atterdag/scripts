#!/bin/sh

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

sudo mkdir -p ${SSL_CA_DIR}/{certs,crl,reqs,newcerts,private}
sudo chown -R root:ssl-cert ${SSL_CA_DIR}/private
sudo chmod 0750 ${SSL_CA_DIR}/private
sed 's|./demoCA|${SSL_CA_DIR}|g' /etc/ssl/openssl.cnf | sudo tee ${SSL_CA_DIR}/openssl.cnf
echo "01" | sudo tee ${SSL_CA_DIR}/serial
echo "01" | sudo tee ${SSL_CA_DIR}/crlnumber
sudo touch ${SSL_CA_DIR}/index.txt

cat << EOF | sudo tee ${SSL_CA_DIR}/openssl.cnf
HOME                           = ${SSL_CA_DIR}
RANDFILE                       = ${SSL_CA_DIR}/.rnd
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

# Generate random numbers
sudo openssl rand \
  -out ${SSL_CA_DIR}/.rnd \
  4096

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

sudo openssl x509 \
  -x509toreq \
  -passin pass:${CA_PASSWORD} \
  -signkey ${SSL_CA_DIR}/private/ca.key \
  -in ${SSL_CA_DIR}/certs/ca.crt \
  -out ${SSL_CA_DIR}/reqs/ca.csr

# Generate new intermediate CA, and certifcate
sudo su -c "openssl req \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -keyout ${SSL_CA_DIR}/private/intermediate.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_CA_DIR}/reqs/intermediate.csr \
  -passout pass:${CA_PASSWORD} \
  -sha256 \
  -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${SSL_INTERMEDIATE_CA_NAME}\" \
  -subject \
  -text"

yes | sudo openssl ca \
  -cert ${SSL_CA_DIR}/certs/ca.crt \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -days 3650 \
  -extensions v3_ca \
  -in ${SSL_CA_DIR}/reqs/intermediate.csr \
  -keyfile ${SSL_CA_DIR}/private/ca.key \
  -keyform PEM \
  -out ${SSL_CA_DIR}/certs/intermediate.crt \
  -passin pass:${CA_PASSWORD}

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
  -cert ${SSL_CA_DIR}/certs/intermediate.crt \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -days 365 \
  -in ${SSL_CA_DIR}/reqs/${CONTROLLER_FQDN}.csr \
  -keyfile ${SSL_CA_DIR}/private/intermediate.key \
  -keyform PEM \
  -out ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.crt \
  -passin pass:${CA_PASSWORD}

# sudo openssl ca \
#   -config ${SSL_CA_DIR}/openssl.cnf \
#   -revoke ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.crt \
#   -passin "pass:${CA_PASSWORD}"

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
  -cert ${SSL_CA_DIR}/certs/intermediate.crt \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -days 365 \
  -in ${SSL_CA_DIR}/reqs/${COMPUTE_FQDN}.csr \
  -keyfile ${SSL_CA_DIR}/private/intermediate.key \
  -keyform PEM \
  -out ${SSL_CA_DIR}/certs/${COMPUTE_FQDN}.crt \
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
sudo cp -f \
  ${SSL_CA_DIR}/certs/intermediate.crt \
  /usr/local/share/ca-certificates/${SSL_INTERMEDIATE_CA_NAME}.crt

# Update OS truststore
sudo update-ca-certificates \
  --verbose \
  --fresh

# Create CA chain
cat \
  ${SSL_CA_DIR}/certs/intermediate.crt \
  ${SSL_CA_DIR}/certs/ca.crt \
| sudo tee ${SSL_CA_DIR}/certs/ca-chain.crt

# Convert PKCS#12 database with the controller keypair
sudo openssl pkcs12 \
  -caname "${SSL_INTERMEDIATE_CA_NAME}" \
  -caname "${SSL_CA_NAME}" \
  -certfile ${SSL_CA_DIR}/certs/ca-chain.crt \
  -export \
  -in ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.crt \
  -inkey ${SSL_CA_DIR}/private/${CONTROLLER_FQDN}.key \
  -name ${CONTROLLER_FQDN} \
  -out ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.p12 \
  -passout "pass:${CONTROLLER_KEYSTORE_PASS}"

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
ServerIdentifier=dir
Suffix=${DS_SUFFIX}
RootDN=cn=Directory Manager
RootDNPwd=${DS_ROOT_PASS}
ds_bename=DB1
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
  -d /etc/dirsrv/slapd-dir/ \
  -n "${SSL_CA_NAME}" \
  -t "C,," \
  -i /usr/local/share/ca-certificates/${SSL_CA_NAME}.crt
sudo certutil \
  -A \
  -d /etc/dirsrv/slapd-dir/ \
  -n "${SSL_INTERMEDIATE_CA_NAME}" \
  -t "C,," \
  -i /usr/local/share/ca-certificates/${SSL_INTERMEDIATE_CA_NAME}.crt
sudo pk12util \
  -i ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.p12 \
  -d /etc/dirsrv/slapd-dir/ \
  -n ${CONTROLLER_FQDN} \
  -K ${CONTROLLER_KEYSTORE_PASS} \
  -W ${CONTROLLER_KEYSTORE_PASS}

sudo certutil \
  -d /etc/dirsrv/slapd-dir/ \
  -L

echo "Internal (Software) Token:${CONTROLLER_KEYSTORE_PASS}" \
| sudo tee /etc/dirsrv/slapd-dir/pin.txt

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

sudo systemctl restart dirsrv@dir.service

# Check encryption configuration
ldapsearch \
  -H ldap://${CONTROLLER_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -Z \
  -b 'cn=encryption,cn=config' \
  -x

cat << EOT | sudo tee -a /etc/dirsrv/admin-serv/adm.conf
sslVersionMin: TLS1.1
sslVersionMax: TLS1.2
EOT

##############################################################################
# Install DogTag
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install dogtag-pki

cat << EOF | sudo tee /var/lib/openstack/dogtag.cfg
[DEFAULT]
pki_instance_name = pki-tomcat
pki_admin_password = ${PKI_ADMIN_PASSWORD}
pki_backup_password = ${PKI_BACKUP_PASSWORD}
pki_client_database_password = ${PKI_CLIENT_DATABASE_PASSWORD}
pki_client_pkcs12_password = ${PKI_CLIENT_PKCS12_PASSWORD}
pki_clone_pkcs12_password = ${PKI_CLONE_PKCS12_PASSWORD}
pki_ds_password = ${DS_ROOT_PASS}
pki_replication_password = ${PKI_REPLICATION_PASSWORD}
pki_security_domain_password = ${PKI_SECURITY_DOMAIN_PASSWORD}
pki_token_password = ${PKI_TOKEN_PASSWORD}

[Tomcat]
pki_clone_pkcs12_password=${PKI_CLONE_PKCS12_PASSWORD}

[CA]
pki_http_port = 8080
pki_https_port = 8443
pki_ajp_port = 8009
pki_tomcat_server_port = 8005
pki_admin_uid = caadmin
pki_admin_password = ${PKI_ADMIN_PASSWORD}
pki_backup_password = ${PKI_BACKUP_PASSWORD}
pki_client_database_password = ${PKI_CLIENT_DATABASE_PASSWORD}
pki_client_pkcs12_password = ${PKI_CLIENT_PKCS12_PASSWORD}
pki_import_admin_cert = False
pki_client_admin_cert = /root/.dogtag/pki-tomcat/ca_admin.cert
pki_ds_hostname = ${CONTROLLER_FQDN}
pki_ds_secure_connection = True
pki_ds_ldaps_port = 636
pki_ds_secure_connection_ca_pem_file = /usr/local/share/ca-certificates/${SSL_CA_NAME}.crt
pki_ds_bind_dn = cn=Directory Manager
pki_ds_password = ${DS_ROOT_PASS}
pki_ds_base_dn = o=pki-tomcat-CA
pki_security_domain_name = ${DNS_DOMAIN} Security Domain
pki_clone_pkcs12_password = ${PKI_CLONE_PKCS12_PASSWORD}
pki_replication_password = ${PKI_REPLICATION_PASSWORD}
pki_security_domain_password = ${PKI_SECURITY_DOMAIN_PASSWORD}
pki_token_password = ${PKI_TOKEN_PASSWORD}
pki_admin_email=caadmin@${DNS_DOMAIN}
EOF
sudo pkispawn -s CA -f /var/lib/openstack/dogtag.cfg

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
