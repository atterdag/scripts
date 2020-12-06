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
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DEPLOY_USER_NAME 'kolla'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DEPLOY_USER_ID '42400'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DEPLOY_USER_SSHKEY ''
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DEPLOY_GROUP_ID '42400'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DEPLOY_GROUP_NAME 'kolla'

# Set NTP server details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NTP_HOST_NAME 'ntp'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NTP_ONE_HOST_NAME 'dexter'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NTP_ONE_IP_ADDRESS '192.168.1.3'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NTP_TWO_HOST_NAME 'didi'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NTP_TWO_IP_ADDRESS '192.168.1.4'

# Set DNS server details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NS_HOST_NAME 'ns'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NS_IP_ADDRESS '192.168.1.3'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NSS_HOST_NAME 'nss'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NSS_IP_ADDRESS '192.168.1.4'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/ROOT_DNS_DOMAIN 'se.lemche.net'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/PC_DNS_SUBZONE 'pc'

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
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_HOST_NAME 'aku'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_IP_ADDRESS '192.168.0.40'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_DNS_REVERSE_ZONE '10.in-addr.arpa'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_DNS_SUB_ZONE 'os'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_HUB_ALLOCATION_START '10.0.0.2'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_HUB_ALLOCATION_STOP '10.0.0.253'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_HUB_DNS_REVERSE_ZONE '0.0.10.in-addr.arpa'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_HUB_DNS_SUB_ZONE 'hub'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_HUB_GATEWAY '10.0.0.254'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_HUB_NETWORK_CIDR '10.0.0.0/24'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_HUB_NETWORK_NAME 'hub'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_SPOKE_ALLOCATION_START '10.1.0.2'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_SPOKE_ALLOCATION_STOP '10.1.0.253'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_SPOKE_DNS_REVERSE_ZONE '0.1.10.in-addr.arpa'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_SPOKE_DNS_SUB_ZONE 'spoke'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_SPOKE_GATEWAY '10.1.0.254'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_SPOKE_NETWORK_CIDR '10.1.0.0/24'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_SPOKE_NETWORK_NAME 'spoke'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_SPOKE_FLOATING_IP_ADDRESS '10.0.0.11'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_SPOKE_EXTERNAL_GATEWAY_IP_ADDRESS '10.0.0.30'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_PROVIDER_ALLOCATION_START '192.168.254.2'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_PROVIDER_ALLOCATION_STOP '192.168.254.253'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_PROVIDER_GATEWAY '192.168.254.254'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_PROVIDER_NAME 'routing'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_PROVIDER_ROUTER_IP_ADDRESS '192.168.254.10'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_PROVIDER_NETWORK_CIDR '192.168.254.0/24'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_PROVIDER_VLAN '1000'

# Set keys with MAAS servers
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_ONE_HOST_NAME 'maas01'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_ONE_IP_ADDRESS '192.168.100.11'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_TWO_HOST_NAME 'maas02'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_TWO_IP_ADDRESS '192.168.100.12'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_DNS_SUBZONE 'maas'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_PG_REPLICATION_USERNAME 'replicator'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_DBUSER 'maas'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_DBNAME 'maasdb'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_ADMIN_USERNAME 'admin'

# Set keys with general DNS/Network used by OpenStack
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_MANAGEMENT_PHYSICAL_NIC 'eth0'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_PROVIDER_PHYSICAL_NIC 'bond0'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/COMPUTE_PROVIDER_VIRTUAL_NIC 'physnet1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_MANAGEMENT_PHYSICAL_NIC 'eth0'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_PROVIDER_PHYSICAL_NIC 'bond0'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/CONTROLLER_PROVIDER_VIRTUAL_NIC 'physnet1'

# Set keys with storage devices used by OpenStack
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/LVM_PREMIUM_PV_DEVICE 'sdb'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/LVM_STANDARD_PV_DEVICE 'sda'

# Will probably be deleted later ...
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SIMPLE_CRYPTO_CA 'OpenStack'

# Set k8s raspberry pi details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_CLUSTER_NAME 'k8srassies'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_CONTROL_PLANE_HOST_NAME 'k8smaster'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_CONTROL_PLANE_IP_ADDRESS '192.168.1.9'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_CONTROL_PLANE_PORT '8443'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_MASTER_ONE_API_PORT '6443'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_MASTER_ONE_HOST_NAME 'k8smaster01'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_MASTER_ONE_IP_ADDRESS '192.168.1.5'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_MASTER_TWO_API_PORT '6443'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_MASTER_TWO_HOST_NAME 'k8smaster02'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_MASTER_TWO_IP_ADDRESS '192.168.1.6'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_POD_NETWORK_CIDR '10.244.0.0/16'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_SERVICE_NETWORK_CIDR '10.96.0.0/12'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_WORKER_ONE_HOST_NAME 'k8sworker01'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_WORKER_ONE_IP_ADDRESS '192.168.1.7'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_WORKER_TWO_HOST_NAME 'k8sworker02'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_WORKER_TWO_IP_ADDRESS '192.168.1.8'

# Where to store OpenStack configuration files
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OPENSTACK_CONFIGURATION_DIRECTORY '/var/lib/openstack'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OPENSTACK_IMAGES_DIRECTORY '/var/cache/openstack'

# Ironic network bootstrap settings
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IRONIC_CLEANING_NETWORK 'bond0'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IRONIC_DNSMASQ_DEFAULT_GATEWAY '192.168.0.1'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IRONIC_DNSMASQ_DHCP_RANGE '192.168.0.66,192.168.0.126'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/IRONIC_DNSMASQ_INTERFACE 'eth0'

# Set Octavia subnet
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OCTAVIA_AMP_NETWORK_CIDR '10.10.10.10/24'

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
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/PC_DNS_DOMAIN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/PC_DNS_SUBZONE).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_DNS_DOMAIN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/OS_DNS_SUB_ZONE).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_HUB_DNS_DOMAIN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/OS_HUB_DNS_SUB_ZONE).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/OS_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/OS_SPOKE_DNS_DOMAIN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/OS_SPOKE_DNS_SUB_ZONE).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/OS_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NTP_ONE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/NTP_ONE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/NTP_TWO_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/NTP_TWO_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_BASE_DIR "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ROOT_DIRECTORY)/$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ORGANIZATION_NAME)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_CA_EMAIL "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_ROOT_CA_EMAIL_USER)@$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_AUDIT_ONE_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_AUDIT_ONE_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME $(echo $(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME) | sed 's/\s/_/g')
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/SSL_INTERMEDIATE_CA_ONE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/SSL_INTERMEDIATE_CA_ONE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
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
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_DNS_DOMAIN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/MAAS_DNS_SUBZONE).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_ONE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/MAAS_ONE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/MAAS_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_TWO_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/MAAS_TWO_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/MAAS_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/MAAS_ADMIN_EMAIL "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/MAAS_ADMIN_USERNAME)@$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/MAAS_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_MASTER_ONE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/K8S_MASTER_ONE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_MASTER_TWO_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/K8S_MASTER_TWO_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_WORKER_ONE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/K8S_WORKER_ONE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_WORKER_TWO_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/K8S_WORKER_TWO_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/K8S_CONTROL_PLANE_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/K8S_CONTROL_PLANE_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/ROOT_DNS_DOMAIN)"
