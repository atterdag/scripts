# About

This is a collection of IBM WebSphere Application Server wsadmin scripts to install, and configure a WAS Full Profile environment.

## Include common.py

No matter which script you use from this collection, you must remember to copy common.py into the same directory with whatever script you copied.

# Running scripts

You run the script with wsadmin like:

```
/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/bin/wsadmin.sh \
 -lang jython \
 -username "wasadmin" \
 -password "passw0rd" \
 -f /srv/git/scripts/was/enable_hpel.py
```

Certain scripts require arguments or switches, for instance:

```
/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/bin/wsadmin.sh \
 -lang jython \
 -username "wasadmin" \
 -password "passw0rd" \
 -f /srv/git/scripts/was/configure_vmm.py \
 --ldapBaseDN=o=example \
 --ldapBindDN=cn=ldapbind,ou=dsa,o=example \
 --ldapBindPW=passw0rd \
 --ldapHostName=ldap.example.com \
 --ldapPort=636 \
 --ldapSSL=true \
 --ldapUserOC=inetOrgPerson \
 --ldapUserIdAttribute=uid \
 --ldapGroupOC=groupOfNames \
 --ldapMemberAttribute=member \
 --ldapMembershipAttribute=ibm-allGroups \
 --ldapType=IDS \
 --primaryAdminId=wasadmin \
 --vmmRealmID=ldap.example.com:636"
```

Or

```
/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/bin/wsadmin.sh \
 -lang jython \
 -username "wasadmin" \
 -password "passw0rd" \
 -f /srv/git/scripts/was/importCACert.py \
 /etc/ssl/cacert.pem \
  example-ca }}"
```
