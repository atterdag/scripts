#!/bin/bash

##############################################################################
# Set OS infrastructure /variables
##############################################################################

# Set URI to etcd server
export ETCDCTL_ENDPOINTS="http://localhost:2379"

# Get the admin password
if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read -s ETCD_ADMIN_PASS; fi

# Set keys with Management server
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/ETCD_ONE_HOST_NAME 'etcd-0'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/ETCD_ONE_IP_ADDRESS '192.168.1.3'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/ETCD_TWO_HOST_NAME 'etcd-1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/ETCD_TWO_IP_ADDRESS '192.168.1.4'

# Set NTP server details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NTP_HOST_NAME 'ntp'

# Set DNS server details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NS_HOST_NAME 'ns'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NS_IP_ADDRESS '192.168.1.3'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NSS_HOST_NAME 'nss'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NSS_IP_ADDRESS '192.168.1.4'

# Set FreeIPA details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/FREEIPA_CONFIGURATION_DIRECTORY '/var/lib/freeipa'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_INSTANCE_NAME 'default'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_ONE_HOST_NAME 'idm1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_ONE_IP_ADDRESS '192.168.1.3'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_TWO_HOST_NAME 'idm2'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_TWO_IP_ADDRESS '192.168.1.4'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_PKI_INSTANCE_NAME 'pki-tomcat'

# Set keys with common details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_DIRECTORY '/var/lib/ssl'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_COUNTRY_NAME 'SE'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_STATE 'Scania'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ORGANIZATION_NAME 'Lemche.NET'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ORGANIZATIONAL_UNIT_NAME 'Security Operation Center'

# Set keys with root ca details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_COMMON_NAME 'Lemche.NET Root CA'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_EMAIL_USER 'ca'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_HOST_NAME 'ca'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_IP_ADDRESS '192.168.0.30'

# Set keys with intermediate cas details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_AUDIT_ONE_COMMON_NAME 'Lemche.NET Intermediate AUDIT 1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME 'Lemche.NET Intermediate AUDIT 2'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_ONE_COMMON_NAME 'Lemche.NET Intermediate CA 1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_ONE_HOST_NAME 'idm1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_ONE_IP_ADDRESS '192.168.1.3'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_TWO_COMMON_NAME 'Lemche.NET Intermediate CA 2'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_TWO_HOST_NAME 'idm2'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_TWO_IP_ADDRESS '192.168.1.4'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_OCSP_ONE_HOST_NAME 'ocsp1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_OCSP_TWO_HOST_NAME 'ocsp2'

# Set keys with octavia cas details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_OCTAVIA_CLIENT_CA_COMMON_NAME 'Lemche.NET Octavia Client CA'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_OCTAVIA_CLIENT_CERT_COMMON_NAME 'Lemche.NET Octavia Client Certificate'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_OCTAVIA_SERVER_CA_COMMON_NAME 'Lemche.NET Octavia Server CA'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_OCTAVIA_SERVER_CERT_COMMON_NAME 'Lemche.NET Octavia Server Certificate'

# Set keys with OpenStack servers
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_HOST_NAME 'jack'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_IP_ADDRESS '192.168.0.30'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_HOST_NAME 'jack'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_IP_ADDRESS '192.168.0.30'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_DNS_SUBZONE 'os'

# Set keys with general DNS/Network used by OpenStack
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_MANAGEMENT_PHYSICAL_NIC 'eno1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_PROVIDER_PHYSICAL_NIC 'bond0'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_PROVIDER_VIRTUAL_NIC 'physnet1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_MANAGEMENT_PHYSICAL_NIC 'eno1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_PROVIDER_PHYSICAL_NIC 'bond0'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_PROVIDER_VIRTUAL_NIC 'physnet1'

# Set keys with storage devices used by OpenStack
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/LVM_PREMIUM_PV_DEVICE 'sdb'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/LVM_STANDARD_PV_DEVICE 'sda'

# Will probably be deleted later ...
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SIMPLE_CRYPTO_CA 'OpenStack'

# Where to store OpenStack configuration files
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OPENSTACK_CONFIGURATION_DIRECTORY '/var/lib/openstack'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OPENSTACK_IMAGES_DIRECTORY '/var/cache/openstack'

# Ironic network bootstrap settings
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IRONIC_CLEANING_NETWORK 'bond0'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IRONIC_DNSMASQ_DEFAULT_GATEWAY '192.168.0.1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IRONIC_DNSMASQ_DHCP_RANGE '192.168.0.66,192.168.0.126'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IRONIC_DNSMASQ_INTERFACE 'eno1'

##############################################################################
# Create calculated keys based of hardcoded keys
##############################################################################
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/COMPUTE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/CONTROLLER_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DNS_REVERSE_DOMAIN "$(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/CONTROLLER_IP_ADDRESS) | awk -F'.' '{print $3"."$2"."$1}').in-addr.arpa"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DS_SUFFIX "dc=$(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN) | sed 's|\.|,dc=|g')"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/ETCD_ONE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ETCD_ONE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/ETCD_TWO_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ETCD_TWO_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_ONE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/IDM_ONE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_TWO_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/IDM_TWO_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/KERBEROS_REALM "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN | tr a-z A-Z)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NS_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/NS_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NSS_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/NSS_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_DNS_DOMAIN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/OS_DNS_SUBZONE).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NTP_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/NTP_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_BASE_DIR "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ROOT_DIRECTORY)/$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ORGANIZATION_NAME)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_CA_EMAIL "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ROOT_CA_EMAIL_USER)@$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_AUDIT_ONE_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_AUDIT_ONE_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_ONE_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_CA_ONE_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_TWO_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_CA_TWO_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_TWO_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_CA_TWO_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_OCSP_ONE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_OCSP_ONE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_OCSP_TWO_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_OCSP_TWO_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_OCTAVIA_CLIENT_CA_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_OCTAVIA_CLIENT_CA_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_OCTAVIA_CLIENT_CERT_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_OCTAVIA_CLIENT_CERT_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_OCTAVIA_SERVER_CA_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_OCTAVIA_SERVER_CA_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_OCTAVIA_SERVER_CERT_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_OCTAVIA_SERVER_CERT_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ROOT_CA_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_STRICT_NAME "$(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ROOT_CA_COMMON_NAME) | sed 's/\s/_/g')"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_BASE_URL "http://$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ROOT_CA_FQDN)"
