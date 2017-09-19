#!/bin/sh

BINDDN="CN=Administrator,CN=Users,DC=EXAMPLE,DC=LAN"
BINDPW="passw0rd"
BASEDN="DC=EXAMPLE,DC=LAN"
LDAPURI="ldap://ad01.example.lan:389"

ldapsearch -u -LLL -x -H $LDAPURI -b $BASEDN -D $BINDDN -w $BINDPW '(&(objectClass=posixAccount)(uid='"$1"'))' 'sshPublicKey' | sed -n '/^ /{H;d};/sshPublicKey:/x;$g;s/\n *//g;s/sshPublicKey: //gp'

# add to /etc/ssh/sshd_config
# AuthorizedKeysCommand /path/to/script
# AuthorizedKeysCommandUser nobody
