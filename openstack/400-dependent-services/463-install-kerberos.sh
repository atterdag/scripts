#!/bin/sh

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
