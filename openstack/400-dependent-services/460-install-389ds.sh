#!/bin/sh

##############################################################################
# Install 389 Directory Server
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install 389-ds

sudo ds_removal -s default -w ${DS_ADMIN_PASS}

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
