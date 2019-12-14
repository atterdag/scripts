#!/bin/bash

##############################################################################
# Install 389 Directory Server
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install \
    389-ds

if [[ $CONTROLLER_FQDN != $IDM_ONE_FQDN ]]; then
  export IDM_ONE_FQDN=$CONTROLLER_FQDN
  export IDM_ONE_IP_ADDRESS=$CONTROLLER_IP_ADDRESS
  export IDM_ONE_KEYSTORE_PASS=$CONTROLLER_KEYSTORE_PASS
fi

# sudo ds_removal -s default -w ${DS_ADMIN_PASS}

cat << EOF | sudo tee /etc/sysctl.d/99-389-ds.conf
net.ipv4.tcp_keepalive_time = 300
net.ipv4.ip_local_port_range = 1024 65000
fs.file-max = 64000
EOF
sudo sysctl --load=/etc/sysctl.d/99-389-ds.conf

cat << EOF | sudo tee /etc/security/limits.d/389-ds.conf
*             -       nofile          8192
EOF
sudo crudini --set /var/lib/openstack/389-ds-setup.inf General FullMachineName "${IDM_ONE_FQDN}"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf General SuiteSpotUserID "dirsrv"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf General SuiteSpotGroup "dirsrv"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf General AdminDomain "${DNS_DOMAIN}"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf General ConfigDirectoryAdminID "admin"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf General ConfigDirectoryAdminPwd "${DS_ADMIN_PASS}"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf General ConfigDirectoryLdapURL "ldap://${IDM_ONE_FQDN}:389/o=NetscapeRoot"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf slapd SlapdConfigForMC "Yes"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf slapd UseExistingMC "0"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf slapd ServerPort "389"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf slapd ServerIdentifier "default"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf slapd Suffix "${DS_SUFFIX}"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf slapd RootDN "cn=Directory Manager"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf slapd RootDNPwd "${DS_ROOT_PASS}"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf slapd AddSampleEntries "Yes"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf admin Port "9830"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf admin ServerIpAddress "${IDM_ONE_IP_ADDRESS}"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf admin ServerAdminID "admin"
sudo crudini --set /var/lib/openstack/389-ds-setup.inf admin ServerAdminPwd "${DS_ADMIN_PASS}"

sudo setup-ds-admin \
  --silent \
  --file=/var/lib/openstack/389-ds-setup.inf

export ETCDCTL_ENDPOINTS="https://${CONTROLLER_FQDN}:4001"
echo $ETCD_USER_PASS > ~/.ETCD_USER_PASS
etcdctl --username user:$ETCD_USER_PASS get keystores/${IDM_ONE_FQDN}.p12 \
| tr -d '\n' \
| base64 --decode \
> ${IDM_ONE_FQDN}.p12
sudo mv ${IDM_ONE_FQDN}.p12 /var/lib/openstack/${IDM_ONE_FQDN}.p12

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
  -i /var/lib/openstack/${IDM_ONE_FQDN}.p12 \
  -d /etc/dirsrv/slapd-default/ \
  -n ${IDM_ONE_FQDN} \
  -K ${IDM_ONE_KEYSTORE_PASS} \
  -W ${IDM_ONE_KEYSTORE_PASS}
sudo certutil \
  -d /etc/dirsrv/slapd-default/ \
  -L

echo "Internal (Software) Token:${IDM_ONE_KEYSTORE_PASS}" \
| sudo tee /etc/dirsrv/slapd-default/pin.txt

cat << EOF | sudo tee /var/lib/openstack/389-ds-enable-security.ldif
dn: cn=config
changetype: modify
replace: nsslapd-security
nsslapd-security: on
EOF

sudo ldapmodify \
  -H ldap://${IDM_ONE_FQDN}:389 \
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
  -H ldap://${IDM_ONE_FQDN}:389 \
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
nsSSLPersonalitySSL: ${IDM_ONE_FQDN}
cn: RSA
EOF

sudo ldapmodify \
  -H ldap://${IDM_ONE_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -x \
  -f /var/lib/openstack/389-ds-add-rsa.ldif

sudo systemctl enable dirsrv@default.service
sudo systemctl restart dirsrv@default.service

# Check encryption configuration
ldapsearch \
  -H ldap://${IDM_ONE_FQDN}:389 \
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
