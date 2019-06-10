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
export ADMIN_PASS=$(genpasswd 16)
export BARBICAN_DBPASS=$(genpasswd 16)
export BARBICAN_PASS=$(genpasswd 16)
export BARBICAN_KEK=$(echo $(genpasswd 32) | base64)
export CA_PASSWORD=$(genpasswd 32)
export CINDER_DBPASS=$(genpasswd 16)
export CINDER_PASS=$(genpasswd 16)
export CONTROLLER_KEYSTORE_PASS=$(genpasswd 16)
export COMPUTE_KEYSTORE_PASS=$(genpasswd 16)
export DASH_DBPASS=$(genpasswd 16)
export DEMO_PASS=$(genpasswd 16)
export DESIGNATE_PASS=$(genpasswd 16)
export DESIGNATE_DBPASS=$(genpasswd 16)
export DS_ADMIN_PASS=$(genpasswd 16)
export DS_ROOT_PASS=$(genpasswd 16)
export GLANCE_DBPASS=$(genpasswd 16)
export GLANCE_PASS=$(genpasswd 16)
export KERBEROS_MASTER_SECRET=$(genpasswd 32)
export KEYSTONE_DBPASS=$(genpasswd 16)
export METADATA_SECRET=$(genpasswd 32)
export NEUTRON_DBPASS=$(genpasswd 16)
export NEUTRON_PASS=$(genpasswd 16)
export NOVA_DBPASS=$(genpasswd 16)
export NOVA_PASS=$(genpasswd 16)
export PKI_ADMIN_PASSWORD=$(genpasswd 16)
export PKI_BACKUP_PASSWORD=$(genpasswd 16)
export PKI_CLIENT_DATABASE_PASSWORD=$(genpasswd 16)
export PKI_CLIENT_PKCS12_PASSWORD=$(genpasswd 16)
export PKI_CLONE_PKCS12_PASSWORD=$(genpasswd 16)
export PKI_REPLICATION_PASSWORD=$(genpasswd 16)
export PKI_SECURITY_DOMAIN_PASSWORD=$(genpasswd 16)
export PKI_TOKEN_PASSWORD=$(genpasswd 16)
export PLACEMENT_PASS=$(genpasswd 16)
export PLACEMENT_DBPASS=$(genpasswd 16)
export RABBIT_PASS=$(genpasswd 16)
export ROOT_DBPASS=$(genpasswd 16)
" \
| sudo tee /var/lib/openstack/os_password.env
sudo chown root:root /var/lib/openstack/os_password.env
sudo chmod 0600 /var/lib/openstack/os_password.env
source <(sudo cat /var/lib/openstack/os_password.env)

##############################################################################
# Set OS infrastructure variables
##############################################################################
cat << EOF | sudo tee /var/lib/openstack/os_environment.env
# Specified values
export DNS_DOMAIN=se.lemche.net
export CONTROLLER_IP_ADDRESS=192.168.1.30
export COMPUTE_IP_ADDRESS=192.168.1.30
export LVM_PREMIUM_PV_DEVICE=sde
export LVM_STANDARD_PV_DEVICE=sdb
export NETWORK_CIDR=192.168.1.0/24
export NETWORK_INTERFACE=eno1
export SIMPLE_CRYPTO_CA=OpenStack
export SSL_CA_NAME=Lemche.NET-CA
export SSL_INTERMEDIATE_CA_NAME=Lemche.NET-Intermediate-CA
export SSL_COUNTRY_NAME=SE
export SSL_STATE=Scania
export SSL_ORGANIZATION_NAME=Lemche.NET
export SSL_ORGANIZATIONAL_UNIT_NAME=Technical

# Calculated values
export CONTROLLER_FQDN=jack.\${DNS_DOMAIN}
export COMPUTE_FQDN=jack.\${DNS_DOMAIN}
export DNS_REVERSE_DOMAIN=\$(echo \$CONTROLLER_IP_ADDRESS | awk -F'.' '{print \$3"."\$2"."\$1}').in-addr.arpa
export DS_SUFFIX='dc='\$(echo \$DNS_DOMAIN | sed 's|\.|,dc=|g')
export SSL_BASE_URL=http://ca.\${DNS_DOMAIN}/ssl
export SSL_CA_DIR=/var/lib/ssl/\${SSL_CA_NAME}
EOF
source <(sudo cat /var/lib/openstack/os_environment.env)

##############################################################################
# Setting up compute node
##############################################################################
# Copy *env files to compute node
source <(sudo cat /var/lib/openstack/os_password.env)
source <(sudo cat /var/lib/openstack/os_environment.env)
