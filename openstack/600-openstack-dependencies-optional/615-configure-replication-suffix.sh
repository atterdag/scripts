#!/bin/bash

##############################################################################
# Install 389 Directory Server
##############################################################################
# Import configuration data to environment
source $HOME/prepare-node.env

# Enable replication on idm2
sudo dsconf \
  -D "cn=Directory Manager" \
  -w "${DS_ROOT_PASS}" \
  ldap://${IDM_TWO_FQDN}:389 \
  replication enable \
    --suffix="${DS_SUFFIX}" \
    --role="master" \
    --replica-id=1 \
    --bind-dn="cn=replication manager,cn=config" \
    --bind-passwd="${DS_REPL_PASS}"

# Enable replicaton on idm1
sudo dsconf \
  -D "cn=Directory Manager" \
  -w "${DS_ROOT_PASS}" \
  ldap://${IDM_ONE_FQDN}:389 \
  replication enable \
    --suffix="${DS_SUFFIX}" \
    --role="master" \
    --replica-id=2 \
    --bind-dn="cn=replication manager,cn=config" \
    --bind-passwd="${DS_REPL_PASS}"

# Create replication agreement from idm1 to idm2
sudo dsconf \
  -D "cn=Directory Manager" \
  -w "${DS_ROOT_PASS}" \
  ldap://${IDM_ONE_FQDN}:389 \
  repl-agmt create \
    --suffix="${DS_SUFFIX}" \
    --host="${IDM_TWO_FQDN}" \
    --port=389 \
    --conn-protocol=StartTLS \
    --bind-dn="cn=replication manager,cn=config" \
    --bind-passwd="${DS_REPL_PASS}" \
    --bind-method=SIMPLE \
    --init \
    suffix-replication-agreement-idm1-to-idm2

# Check replication status
sudo dsconf \
  -D "cn=Directory Manager" \
  -w "${DS_ROOT_PASS}" \
  ldap://${IDM_ONE_FQDN}:389 \
  repl-agmt init-status \
    --suffix="${DS_SUFFIX}" \
    suffix-replication-agreement-idm1-to-idm2

# Create replication agreement from idm1 to idm2
sudo dsconf \
  -D "cn=Directory Manager" \
  -w "${DS_ROOT_PASS}" \
  ldap://${IDM_TWO_FQDN}:389 \
  repl-agmt create \
    --suffix="${DS_SUFFIX}" \
    --host="${IDM_ONE_FQDN}" \
    --port=389 \
   --conn-protocol=StartTLS \
   --bind-dn="cn=replication manager,cn=config" \
   --bind-passwd="${DS_REPL_PASS}" \
   --bind-method=SIMPLE \
   --init \
   suffix-replication-agreement-idm2-to-idm1

# Check replication status
sudo dsconf \
  -D "cn=Directory Manager" \
  -w "${DS_ROOT_PASS}" \
  ldap://${IDM_TWO_FQDN}:389 \
  repl-agmt init-status \
    --suffix="${DS_SUFFIX}" \
    suffix-replication-agreement-idm2-to-idm1

cat <<EOF \
| ldapmodify \
  -H ldap://${IDM_ONE_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -Z \
  -x
dn: ou=test_ou,dc=se,dc=lemche,dc=net
changetype: add
objectClass: organizationalUnit
objectClass: top
ou: test_ou
EOF

ldapsearch \
  -H ldap://${IDM_TWO_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -Z \
  -b 'dc=se,dc=lemche,dc=net' \
  -x \
  "(ou=test_ou)"

cat <<EOF \
| ldapmodify \
  -H ldap://${IDM_TWO_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -Z \
  -x
dn: ou=test_ou,dc=se,dc=lemche,dc=net
changetype: delete
EOF

ldapsearch \
  -H ldap://${IDM_ONE_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -Z \
  -b 'dc=se,dc=lemche,dc=net' \
  -x \
  "(ou=test_ou)"
