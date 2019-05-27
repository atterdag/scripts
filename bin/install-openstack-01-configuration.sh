#!/bin/sh

##############################################################################
# Create directory to store openstack files
##############################################################################
sudo mkdir -p /var/lib/openstack/
sudo chown root:root /var/lib/openstack/
sudo chmod 0700 /var/lib/openstack/

##############################################################################
# Set password variables on controller node
##############################################################################
genpasswd() {
	local l=$1
       	[ "$l" == "" ] && l=16
      	tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}

echo "\
export ROOT_DBPASS=$(genpasswd 16)
export ADMIN_PASS=$(genpasswd 16)
export BARBICAN_DBPASS=$(genpasswd 16)
export BARBICAN_PASS=$(genpasswd 16)
export BARBICAN_KEK=$(echo $(genpasswd 32) | base64)
export CINDER_DBPASS=$(genpasswd 16)
export CINDER_PASS=$(genpasswd 16)
export DASH_DBPASS=$(genpasswd 16)
export DEMO_PASS=$(genpasswd 16)
export DESIGNATE_PASS=$(genpasswd 16)
export DESIGNATE_DBPASS=$(genpasswd 16)
export DEMO_PASS=$(genpasswd 16)
export GLANCE_DBPASS=$(genpasswd 16)
export GLANCE_PASS=$(genpasswd 16)
export KEYSTONE_DBPASS=$(genpasswd 16)
export METADATA_SECRET=$(genpasswd 32)
export NEUTRON_DBPASS=$(genpasswd 16)
export NEUTRON_PASS=$(genpasswd 16)
export NOVA_DBPASS=$(genpasswd 16)
export NOVA_PASS=$(genpasswd 16)
export PLACEMENT_PASS=$(genpasswd 16)
export PLACEMENT_DBPASS=$(genpasswd 16)
export RABBIT_PASS=$(genpasswd 16)
export CA_PASSWORD=$(genpasswd 32)
" \
| sudo tee /var/lib/openstack/os_password.env
sudo chown root:root /var/lib/openstack/os_password.env
sudo chmod 0600 /var/lib/openstack/os_password.env
source <(sudo cat /var/lib/openstack/os_password.env)

##############################################################################
# Set OS infrastructure variables
##############################################################################
cat << EOF | sudo tee /var/lib/openstack/os_environment.env
export CONTROLLER_FQDN=jack.se.lemche.net
export CONTROLLER_IP_ADDRESS=192.168.1.30
export COMPUTE_FQDN=jack.se.lemche.net
export COMPUTE_IP_ADDRESS=192.168.1.30
export NETWORK_CIDR=192.168.1.0/24
export NETWORK_INTERFACE=eno1
export LVM_PV_DEVICE=sdb
export DNS_DOMAIN=se.lemche.net
export SIMPLE_CRYPTO_CA=OpenStack
export SSL_CA_NAME=Lemche.NET-CA
export SSL_COUNTRY_NAME=SE
export SSL_STATE=Scania
export SSL_ORGANIZATION_NAME=Lemche.NET
export SSL_ORGANIZATIONAL_UNIT_NAME=Technical
export SSL_BASE_URL=http://ca.se.lemche.net/ssl
export SSL_CA_DIR=/var/lib/ssl/${SSL_CA_NAME}
EOF
source <(sudo cat /var/lib/openstack/os_environment.env)

##############################################################################
# Setting up compute node
##############################################################################
# Copy *env files to compute node
source <(sudo cat /var/lib/openstack/os_password.env)
source <(sudo cat /var/lib/openstack/os_environment.env)
