#!/bin/sh

##############################################################################
# Create directory to store openstack files
##############################################################################
mkdir -p /var/lib/openstack/
chown root:root /var/lib/openstack/
chmod 0700 /var/lib/openstack/

##############################################################################
# Set password variables
##############################################################################
apt-get --yes install apg

APG_COMMAND="apg -m 16 -q -n 1 -a 1 -M NCL"
echo "\
ROOT_DBPASS=$($APG_COMMAND)
ADMIN_PASS=$($APG_COMMAND)
BARBICAN_DBPASS=$($APG_COMMAND)
BARBICAN_PASS=$($APG_COMMAND)
BARBICAN_KEK=$(echo $(apg -m 32 -q -n 1 -a 1 -M NCL) | base64)
CINDER_DBPASS=$($APG_COMMAND)
CINDER_PASS=$($APG_COMMAND)
DASH_DBPASS=$($APG_COMMAND)
DESIGNATE_PASS=$($APG_COMMAND)
DESIGNATE_DBPASS=$($APG_COMMAND)
DEMO_PASS=$($APG_COMMAND)
GLANCE_DBPASS=$($APG_COMMAND)
GLANCE_PASS=$($APG_COMMAND)
KEYSTONE_DBPASS=$($APG_COMMAND)
NEUTRON_DBPASS=$($APG_COMMAND)
NEUTRON_PASS=$($APG_COMMAND)
NOVA_DBPASS=$($APG_COMMAND)
NOVA_PASS=$($APG_COMMAND)
RABBIT_PASS=$($APG_COMMAND)
METADATA_PROXY_SHARED_SECRET=$(apg -m 32 -q -n 1 -a 1 -M NCL)
CA_PASSWORD=$(apg -m 32 -q -n 1 -a 1 -M NCL)
" \
> /var/lib/openstack/os_password.txt
chown root:root /var/lib/openstack/os_password.txt
chmod 0600 /var/lib/openstack/os_password.txt
source /var/lib/openstack/os_password.txt

##############################################################################
# Set OS infrastructure variables
##############################################################################
CONTROLLER_FQDN=etch.se.lemche.net
CONTROLLER_IP_ADDRESS=192.168.1.40
COMPUTE_FQDN=etch.se.lemche.net
COMPUTE_IP_ADDRESS=192.168.1.40
NETWORK_CIDR=192.168.1.0/24
NETWORK_INTERFACE=bond0
LVM_PV_DEVICE=sda
DNS_DOMAIN=se.lemche.net
SIMPLE_CRYPTO_CA=OpenStack
SSL_CA_NAME=Lemche.NET-CA
SSL_COUNTRY_NAME=SE
SSL_STATE=Scania
SSL_ORGANIZATION_NAME=Lemche.NET
SSL_ORGANIZATIONAL_UNIT_NAME=Technical
SSL_BASE_URL=http://ca.se.lemche.net/ssl
SSL_CA_DIR=/var/lib/ssl/${SSL_CA_NAME}
