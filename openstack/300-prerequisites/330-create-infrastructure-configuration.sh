#!/bin/sh

##############################################################################
# Set OS infrastructure variables
##############################################################################
# Create a etcd directory to store keys under
etcdctl mkdir openstack

# Create hardcoded keys
etcdctl mk openstack/COMPUTE_HOST_NAME 'jack'
etcdctl mk openstack/COMPUTE_IP_ADDRESS '192.168.1.30'
etcdctl mk openstack/CONTROLLER_HOST_NAME 'jack'
etcdctl mk openstack/CONTROLLER_IP_ADDRESS '192.168.1.30'
etcdctl mk openstack/DNS_DOMAIN 'se.lemche.net'
etcdctl mk openstack/LVM_PREMIUM_PV_DEVICE 'sdb'
etcdctl mk openstack/LVM_STANDARD_PV_DEVICE 'sde'
etcdctl mk openstack/NETWORK_CIDR '192.168.1.0/24'
etcdctl mk openstack/NETWORK_INTERFACE 'eno1'
etcdctl mk openstack/SIMPLE_CRYPTO_CA 'OpenStack'
etcdctl mk openstack/SSL_COUNTRY_NAME 'SE'
etcdctl mk openstack/SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME 'Lemche.NET Intermediate AUDIT 2'
etcdctl mk openstack/SSL_INTERMEDIATE_CA_ONE_COMMON_NAME 'Lemche.NET Intermediate CA 1'
etcdctl mk openstack/SSL_INTERMEDIATE_CA_TWO_COMMON_NAME 'Lemche.NET Intermediate CA 2'
etcdctl mk openstack/SSL_INTERMEDIATE_OCSP_ONE_HOSTNAME 'ocsp1'
etcdctl mk openstack/SSL_INTERMEDIATE_OCSP_TWO_HOSTNAME 'ocsp2'
etcdctl mk openstack/SSL_ORGANIZATION_NAME 'Lemche.NET'
etcdctl mk openstack/SSL_ORGANIZATIONAL_UNIT_NAME 'Security Operation Center'
etcdctl mk openstack/SSL_PKI_INSTANCE_NAME 'pki-tomcat'
etcdctl mk openstack/SSL_ROOT_CA_COMMON_NAME 'Lemche.NET Root CA'
etcdctl mk openstack/SSL_ROOT_CA_EMAIL_USER 'ca'
etcdctl mk openstack/SSL_ROOT_CA_HOST_NAME 'ca'
etcdctl mk openstack/SSL_STATE 'Scania'

# Create calculated keys based of hardcoded keys
etcdctl mk openstack/COMPUTE_FQDN "$(etcdctl get openstack/COMPUTE_HOST_NAME).$(etcdctl get openstack/DNS_DOMAIN)"
etcdctl mk openstack/CONTROLLER_FQDN "$(etcdctl get openstack/CONTROLLER_HOST_NAME).$(etcdctl get openstack/DNS_DOMAIN)"
etcdctl mk openstack/DNS_REVERSE_DOMAIN "$(echo $(etcdctl get openstack/CONTROLLER_IP_ADDRESS) | awk -F'.' '{print $3"."$2"."$1}').in-addr.arpa"
etcdctl mk openstack/DS_SUFFIX "dc=$(echo $(etcdctl get openstack/DNS_DOMAIN) | sed 's|\.|,dc |g')"
etcdctl mk openstack/SSL_BASE_DIR "/var/lib/ssl/$(etcdctl get openstack/SSL_ORGANIZATION_NAME)"
etcdctl mk openstack/SSL_ROOT_CA_FQDN "$(etcdctl get openstack/SSL_ROOT_CA_HOST_NAME).$(etcdctl get openstack/DNS_DOMAIN)"
etcdctl mk openstack/SSL_BASE_URL "http://${SSL_ROOT_CA_FQDN}"
etcdctl mk openstack/SSL_CA_EMAIL "$(etcdctl get openstack/SSL_ROOT_CA_EMAIL_USER)@$(etcdctl get openstack/DNS_DOMAIN)"
etcdctl mk openstack/SSL_INTERMEDIATE_AUDIT_TWO_STRICT_NAME $(echo $(etcdctl get openstack/SSL_INTERMEDIATE_AUDIT_TWO_COMMON_NAME) | sed 's/\s/_/g')
etcdctl mk openstack/SSL_INTERMEDIATE_CA_ONE_STRICT_NAME $(echo $(etcdctl get openstack/SSL_INTERMEDIATE_CA_ONE_COMMON_NAME) | sed 's/\s/_/g')
etcdctl mk openstack/SSL_INTERMEDIATE_CA_TWO_STRICT_NAME $(echo $(etcdctl get openstack/SSL_INTERMEDIATE_CA_TWO_COMMON_NAME) | sed 's/\s/_/g')
etcdctl mk openstack/SSL_INTERMEDIATE_OCSP_ONE_FQDN "$(etcdctl get openstack/SSL_INTERMEDIATE_OCSP_ONE_HOSTNAME).$(etcdctl get openstack/DNS_DOMAIN)"
etcdctl mk openstack/SSL_INTERMEDIATE_OCSP_TWO_FQDN "$(etcdctl get openstack/SSL_INTERMEDIATE_OCSP_TWO_HOSTNAME).$(etcdctl get openstack/DNS_DOMAIN)"
etcdctl mk openstack/SSL_ROOT_CA_STRICT_NAME "$(echo $(etcdctl get openstack/SSL_ROOT_CA_COMMON_NAME) | sed 's/\s/_/g')"

# Set environment variables
for key in $(etcdctl ls openstack/ | sed 's|^/openstack/||'); do
	export eval $key="$(etcdctl get openstack/$key)"
done
