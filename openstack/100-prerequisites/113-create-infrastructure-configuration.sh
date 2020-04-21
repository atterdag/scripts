#!/bin/bash

##############################################################################
# Set OS infrastructure /variables
##############################################################################

# Set URI to etcd server
export ETCDCTL_ENDPOINTS="http://localhost:2379"

# Get the admin password
ETCD_ADMIN_PASS=$(cat ~/.ETCD_ADMIN_PASS)

# Set keys with Management server
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MANAGEMENT_HOST_NAME 'aku'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MANAGEMENT_IP_ADDRESS '192.168.0.40'

# Set keys with OpenStack servers
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_HOST_NAME 'jack'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_IP_ADDRESS '192.168.0.30'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_HOST_NAME 'jack'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_IP_ADDRESS '192.168.0.30'

# Set keys with general DNS/Network used by OpenStack
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DNS_DOMAIN 'se.lemche.net'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NETWORK_CIDR '192.168.0.0/24'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_MANAGEMENT_PHYSICAL_NIC 'eno1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_MANAGEMENT_PHYSICAL_NIC 'eno1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_PROVIDER_PHYSICAL_NIC 'bond0'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_PROVIDER_PHYSICAL_NIC 'bond0'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_PROVIDER_VIRTUAL_NIC 'physnet1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_PROVIDER_VIRTUAL_NIC 'physnet1'

# Set keys with storage devices used by OpenStack
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/LVM_STANDARD_PV_DEVICE 'sda'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/LVM_PREMIUM_PV_DEVICE 'sdb'

# Will probably be deleted later ...
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SIMPLE_CRYPTO_CA 'OpenStack'

# Where to store OpenStack configuration files
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OPENSTACK_CONFIGURATION_DIRECTORY '/var/lib/openstack'

# Set NTP server details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NTP_HOST_NAME 'ntp'

# External DNS servers
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DNS_ONE_IP_ADDRESS '192.168.0.1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DNS_TWO_IP_ADDRESS '192.168.0.30'

# Set DNS server details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NS_HOST_NAME 'ns'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NS_IP_ADDRESS '192.168.0.1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NSS_HOST_NAME 'jack'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NSS_IP_ADDRESS '192.168.0.30'

# Set FreeIPA details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_ONE_HOST_NAME 'aku'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_ONE_IP_ADDRESS '192.168.0.40'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_TWO_HOST_NAME 'jack'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_TWO_IP_ADDRESS '192.168.0.30'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_PKI_INSTANCE_NAME 'pki-tomcat'

# Set keys with CA details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_HOST_NAME 'ca'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_IP_ADDRESS '192.168.0.30'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_ONE_HOST_NAME 'ca'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_ONE_IP_ADDRESS '192.168.0.30'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_TWO_HOST_NAME 'idm1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_TWO_IP_ADDRESS '192.168.0.33'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_OCSP_ONE_HOST_NAME 'ocsp1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_OCSP_TWO_HOST_NAME 'ocsp2'

# SSL CA common names
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_AUDIT_ONE_COMMON_NAME 'Lemche.NET Intermediate AUDIT 1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME 'Lemche.NET Intermediate AUDIT 2'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_ONE_COMMON_NAME 'Lemche.NET Intermediate CA 1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_TWO_COMMON_NAME 'Lemche.NET Intermediate CA 2'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_COMMON_NAME 'Lemche.NET Root CA'

# SSL common keys
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_COUNTRY_NAME 'SE'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_STATE 'Scania'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ORGANIZATION_NAME 'Lemche.NET'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ORGANIZATIONAL_UNIT_NAME 'Security Operation Center'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_EMAIL_USER 'ca'

##############################################################################
# Create calculated keys based of hardcoded keys
##############################################################################
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MANAGEMENT_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/MANAGEMENT_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/COMPUTE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/CONTROLLER_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DNS_REVERSE_DOMAIN "$(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/CONTROLLER_IP_ADDRESS) | awk -F'.' '{print $3"."$2"."$1}').in-addr.arpa"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DS_SUFFIX "dc=$(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN) | sed 's|\.|,dc=|g')"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NTP_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/NTP_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NS_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/NS_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NSS_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/NSS_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_ONE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/IDM_ONE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IDM_TWO_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/IDM_TWO_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/KERBEROS_REALM "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN | tr a-z A-Z)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ROOT_CA_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_ONE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_CA_ONE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_TWO_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_CA_TWO_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_OCSP_ONE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_OCSP_ONE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_OCSP_TWO_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_OCSP_TWO_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_ROOT_CA_STRICT_NAME "$(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ROOT_CA_COMMON_NAME) | sed 's/\s/_/g')"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_AUDIT_ONE_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_AUDIT_ONE_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_ONE_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_CA_ONE_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_TWO_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_CA_TWO_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_BASE_DIR "/var/lib/ssl/$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ORGANIZATION_NAME)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_BASE_URL "http://$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ROOT_CA_FQDN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_CA_EMAIL "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ROOT_CA_EMAIL_USER)@$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
