#!/bin/bash

##############################################################################
# Create DC
##############################################################################
sudo apt-get install --yes \
  ldap-utils

cat << EOF | sudo tee /var/lib/openstack/389-ds-create-os-dses.ldif
dn: ou=Roles,${DS_SUFFIX}
objectClass: top
objectClass: organizationalUnit
ou: Roles

dn: uid=admin,ou=People,dc=se,dc=lemche,dc=net
changetype: add
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
objectClass: top
uid: admin
userPassword: ${ADMIN_PASS}
sn: Administrator
cn: OpenStack Administrator
EOF

sudo ldapadd \
  -H ldap://${IDM_ONE_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -x \
  -f /var/lib/openstack/389-ds-create-os-dses.ldif
