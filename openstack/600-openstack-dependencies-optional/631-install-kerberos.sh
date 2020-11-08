#!/bin/bash

##############################################################################
# Install Kerberos Master
##############################################################################
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install \
  krb5-kdc \
  krb5-admin-server

cat << EOF | sudo tee /etc/krb5.conf
[libdefaults]
        default_realm = ${KERBEROS_REALM}
        kdc_timesync = 1
        ccache_type = 4
        forwardable = true
        proxiable = true
        fcc-mit-ticketflags = true

[realms]
        ${KERBEROS_REALM} = {
                kdc = ${IDM_ONE_FQDN}
                admin_server = ${IDM_ONE_FQDN}
        }

[domain_realm]
        .${ROOT_ROOT_DNS_DOMAIN}t = ${KERBEROS_REALM}
        ${ROOT_ROOT_DNS_DOMAIN}t = ${KERBEROS_REALM}
EOF

sudo kdb5_util \
  -P ${KERBEROS_MASTER_SECRET} \
  create \
  -s

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
