#!/bin/bash

##############################################################################
# Set OS infrastructure variables
##############################################################################
# Create a etcd directory to store keys under
etcdctl mkdir variables

# Set keys with OpenStack servers
etcdctl mk variables/CONTROLLER_HOST_NAME 'aku'
etcdctl mk variables/CONTROLLER_IP_ADDRESS '192.168.1.40'
etcdctl mk variables/COMPUTE_HOST_NAME 'jack'
etcdctl mk variables/COMPUTE_IP_ADDRESS '192.168.1.30'

# Set keys with general DNS/Network used by OpenStack
etcdctl mk variables/DNS_DOMAIN 'se.lemche.net'
etcdctl mk variables/NETWORK_CIDR '192.168.1.0/24'
etcdctl mk variables/NETWORK_INTERFACE 'bond0'

# Set keys with storage devices used by OpenStack
etcdctl mk variables/LVM_PREMIUM_PV_DEVICE 'sdb'
etcdctl mk variables/LVM_STANDARD_PV_DEVICE 'sde'

# Will probably be deleted later ...
etcdctl mk variables/SIMPLE_CRYPTO_CA 'OpenStack'

# Set NTP server details
etcdctl mk variables/NTP_HOST_NAME 'aku'
etcdctl mk variables/NTP_IP_ADDRESS '192.168.1.40'

# External DNS servers
etcdctl mk variables/DNS_ONE_IP_ADDRESS '192.168.1.40'
etcdctl mk variables/DNS_TWO_IP_ADDRESS '192.168.1.30'

# Set DNS server details
etcdctl mk variables/NS_HOST_NAME 'aku'
etcdctl mk variables/NS_IP_ADDRESS '192.168.1.40'
etcdctl mk variables/NSS_HOST_NAME 'jack'
etcdctl mk variables/NSS_IP_ADDRESS '192.168.1.30'

# Set FreeIPA details
etcdctl mk variables/IDM_ONE_HOST_NAME 'aku'
etcdctl mk variables/IDM_ONE_IP_ADDRESS '192.168.1.40'
etcdctl mk variables/IDM_TWO_HOST_NAME 'jack'
etcdctl mk variables/IDM_TWO_IP_ADDRESS '192.168.1.30'
etcdctl mk variables/SSL_PKI_INSTANCE_NAME 'pki-tomcat'

# Set keys with CA details
etcdctl mk variables/SSL_ROOT_CA_HOST_NAME 'ca'
etcdctl mk variables/SSL_ROOT_CA_IP_ADDRESS '192.168.1.30'
etcdctl mk variables/SSL_INTERMEDIATE_CA_ONE_HOST_NAME 'ca'
etcdctl mk variables/SSL_INTERMEDIATE_CA_ONE_IP_ADDRESS '192.168.1.30'
etcdctl mk variables/SSL_INTERMEDIATE_CA_TWO_HOST_NAME 'idm1'
etcdctl mk variables/SSL_INTERMEDIATE_CA_TWO_IP_ADDRESS '192.168.1.33'
etcdctl mk variables/SSL_INTERMEDIATE_OCSP_ONE_HOST_NAME 'ocsp1'
etcdctl mk variables/SSL_INTERMEDIATE_OCSP_TWO_HOST_NAME 'ocsp2'

# SSL CA common names
etcdctl mk variables/SSL_INTERMEDIATE_AUDIT_ONE_COMMON_NAME 'Lemche.NET Intermediate AUDIT 1'
etcdctl mk variables/SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME 'Lemche.NET Intermediate AUDIT 2'
etcdctl mk variables/SSL_INTERMEDIATE_CA_ONE_COMMON_NAME 'Lemche.NET Intermediate CA 1'
etcdctl mk variables/SSL_INTERMEDIATE_CA_TWO_COMMON_NAME 'Lemche.NET Intermediate CA 2'
etcdctl mk variables/SSL_ROOT_CA_COMMON_NAME 'Lemche.NET Root CA'

# SSL common keys
etcdctl mk variables/SSL_COUNTRY_NAME 'SE'
etcdctl mk variables/SSL_STATE 'Scania'
etcdctl mk variables/SSL_ORGANIZATION_NAME 'Lemche.NET'
etcdctl mk variables/SSL_ORGANIZATIONAL_UNIT_NAME 'Security Operation Center'
etcdctl mk variables/SSL_ROOT_CA_EMAIL_USER 'ca'

##############################################################################
# Create calculated keys based of hardcoded keys
##############################################################################
etcdctl mk variables/COMPUTE_FQDN "$(etcdctl get variables/COMPUTE_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/CONTROLLER_FQDN "$(etcdctl get variables/CONTROLLER_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/DNS_REVERSE_DOMAIN "$(echo $(etcdctl get variables/CONTROLLER_IP_ADDRESS) | awk -F'.' '{print $3"."$2"."$1}').in-addr.arpa"
etcdctl mk variables/DS_SUFFIX "dc=$(echo $(etcdctl get variables/DNS_DOMAIN) | sed 's|\.|,dc=|g')"
etcdctl mk variables/NTP_FQDN "$(etcdctl get variables/NTP_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/NS_FQDN "$(etcdctl get variables/NS_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/NSS_FQDN "$(etcdctl get variables/NSS_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/IDM_ONE_FQDN "$(etcdctl get variables/IDM_ONE_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/IDM_TWO_FQDN "$(etcdctl get variables/IDM_TWO_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/KERBEROS_REALM "$(etcdctl get variables/DNS_DOMAIN | tr a-z A-Z)"
etcdctl mk variables/SSL_ROOT_CA_FQDN "$(etcdctl get variables/SSL_ROOT_CA_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/SSL_INTERMEDIATE_CA_ONE_FQDN "$(etcdctl get variables/SSL_INTERMEDIATE_CA_ONE_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/SSL_INTERMEDIATE_CA_TWO_FQDN "$(etcdctl get variables/SSL_INTERMEDIATE_CA_TWO_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/SSL_INTERMEDIATE_OCSP_ONE_FQDN "$(etcdctl get variables/SSL_INTERMEDIATE_OCSP_ONE_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/SSL_INTERMEDIATE_OCSP_TWO_FQDN "$(etcdctl get variables/SSL_INTERMEDIATE_OCSP_TWO_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/SSL_ROOT_CA_STRICT_NAME "$(echo $(etcdctl get variables/SSL_ROOT_CA_COMMON_NAME) | sed 's/\s/_/g')"
etcdctl mk variables/SSL_INTERMEDIATE_AUDIT_ONE_STRICT_NAME $(echo $(etcdctl get variables/SSL_INTERMEDIATE_AUDIT_ONE_COMMON_NAME) | sed 's/\s/_/g')
etcdctl mk variables/SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME $(echo $(etcdctl get variables/SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME) | sed 's/\s/_/g')
etcdctl mk variables/SSL_INTERMEDIATE_CA_ONE_STRICT_NAME $(echo $(etcdctl get variables/SSL_INTERMEDIATE_CA_ONE_COMMON_NAME) | sed 's/\s/_/g')
etcdctl mk variables/SSL_INTERMEDIATE_CA_TWO_STRICT_NAME $(echo $(etcdctl get variables/SSL_INTERMEDIATE_CA_TWO_COMMON_NAME) | sed 's/\s/_/g')
etcdctl mk variables/SSL_BASE_DIR "/var/lib/ssl/$(etcdctl get variables/SSL_ORGANIZATION_NAME)"
etcdctl mk variables/SSL_BASE_URL "http://$(etcdctl get variables/SSL_ROOT_CA_FQDN)"
etcdctl mk variables/SSL_CA_EMAIL "$(etcdctl get variables/SSL_ROOT_CA_EMAIL_USER)@$(etcdctl get variables/DNS_DOMAIN)"
