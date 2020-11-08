#!/bin/sh

echo '***'
echo '*** enable virtualenv'
echo '***'
if [[ -z ${WORKON_ON+x} ]]; then workon kolla; fi

echo '***'
echo '*** import OpenStack variables from etcd'
echo '***'
source prepare-node.env

echo '***'
echo '*** create kolla configuration directory'
echo '***'
if [[ ! -d /etc/kolla ]]; then
  sudo mkdir -p /etc/kolla
  sudo chown $USER:$USER /etc/kolla
fi

echo '***'
echo '*** create kolla certificates directory'
echo '***'
if [[ ! -d /etc/kolla/certificates/ca ]]; then
  mkdir -p /etc/kolla/certificates/ca
fi

echo '***'
echo '*** import SSL key pair for haproxy'
echo '***'
etcdctl --username user:$ETCD_USER_PASS get /keystores/HAPROXY.p12 \
| tr -d '\n' \
| base64 --decode \
> ${HAPROXY_FQDN}.p12

openssl pkcs12 \
  -in ${HAPROXY_FQDN}.p12 \
  -passin pass:${HAPROXY_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| tee /etc/kolla/certificates/haproxy-internal.pem

openssl pkcs12 \
  -in ${HAPROXY_FQDN}.p12 \
  -passin pass:${HAPROXY_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| openssl rsa 2>/dev/null \
| tee -a /etc/kolla/certificates/haproxy-internal.pem

openssl pkcs12 \
  -in ${HAPROXY_FQDN}.p12 \
  -passin pass:${HAPROXY_KEYSTORE_PASS} \
  -nokeys \
  -cacerts \
| tee /etc/kolla/certificates/ca/haproxy-internal.crt

rm -f ${HAPROXY_FQDN}.p12

echo '***'
echo '*** import SSL key pair for controller'
echo '***'
etcdctl --username user:$ETCD_USER_PASS get /keystores/CONTROLLER.p12 \
| tr -d '\n' \
| base64 --decode \
> ${CONTROLLER_FQDN}.p12

openssl pkcs12 \
  -in ${CONTROLLER_FQDN}.p12 \
  -passin pass:${CONTROLLER_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| tee /etc/kolla/certificates/controller-cert.pem

openssl pkcs12 \
  -in ${CONTROLLER_FQDN}.p12 \
  -passin pass:${CONTROLLER_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| openssl rsa 2>/dev/null \
| tee /etc/kolla/certificates/controller-key.pem

rm -f ${CONTROLLER_FQDN}.p12

echo '***'
echo '*** import SSL key pair for backend'
echo '***'
etcdctl --username user:$ETCD_USER_PASS get /keystores/COMPUTE.p12 \
| tr -d '\n' \
| base64 --decode \
> ${COMPUTE_FQDN}.p12

openssl pkcs12 \
  -in ${COMPUTE_FQDN}.p12 \
  -passin pass:${COMPUTE_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| tee /etc/kolla/certificates/backend-cert.pem

openssl pkcs12 \
  -in ${COMPUTE_FQDN}.p12 \
  -passin pass:${COMPUTE_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| openssl rsa 2>/dev/null \
| tee /etc/kolla/certificates/backend-key.pem

rm -f ${COMPUTE_FQDN}.p12

echo '***'
echo '*** create kolla certificates directory'
echo '***'
if [[ ! -d /etc/kolla/config/octavia ]]; then
  mkdir -p /etc/kolla/config/octavia
fi

echo '***'
echo '*** import Octavia server CA'
echo '***'
etcdctl --username user:$ETCD_USER_PASS get /keystores/SSL_OCTAVIA_SERVER_CA.p12 \
| tr -d '\n' \
| base64 --decode \
> ${SSL_OCTAVIA_SERVER_CA_STRICT_NAME}.p12

openssl pkcs12 \
  -in ${SSL_OCTAVIA_SERVER_CA_STRICT_NAME}.p12 \
  -passin pass:${SSL_OCTAVIA_SERVER_CA_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| tee /etc/kolla/config/octavia/server_ca.cert.pem

openssl pkcs12 \
  -in ${SSL_OCTAVIA_SERVER_CA_STRICT_NAME}.p12 \
  -passin pass:${SSL_OCTAVIA_SERVER_CA_KEYSTORE_PASS} \
  -passout pass:${SSL_OCTAVIA_SERVER_CA_PASSWORD} \
  -nocerts \
| tee /etc/kolla/config/octavia/server_ca.key.pem

rm -f ${SSL_OCTAVIA_SERVER_CA_STRICT_NAME}.p12

echo '***'
echo '*** import Octavia client certificate and CA'
echo '***'
etcdctl --username user:$ETCD_USER_PASS get /keystores/SSL_OCTAVIA_CLIENT_CERT.p12 \
| tr -d '\n' \
| base64 --decode \
> ${SSL_OCTAVIA_CLIENT_CERT_STRICT_NAME}.p12

openssl pkcs12 \
  -in ${SSL_OCTAVIA_CLIENT_CERT_STRICT_NAME}.p12 \
  -passin pass:${SSL_OCTAVIA_CLIENT_CERT_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| tee /etc/kolla/config/octavia/client.cert-and-key.pem

openssl pkcs12 \
  -in ${SSL_OCTAVIA_CLIENT_CERT_STRICT_NAME}.p12 \
  -passin pass:${SSL_OCTAVIA_CLIENT_CERT_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| openssl rsa 2>/dev/null \
| tee -a /etc/kolla/config/octavia/client.cert-and-key.pem

openssl pkcs12 \
  -in ${SSL_OCTAVIA_CLIENT_CERT_STRICT_NAME}.p12 \
  -passin pass:${SSL_OCTAVIA_CLIENT_CERT_KEYSTORE_PASS} \
  -nokeys \
  -cacerts \
| openssl x509 \
| tee /etc/kolla/config/octavia/client_ca.cert.pem

rm -f ${SSL_OCTAVIA_CLIENT_CERT_STRICT_NAME}.p12

echo '***'
echo '*** copy internal certs to external ones'
echo '***'
cp \
  /etc/kolla/certificates/haproxy-internal.pem \
  /etc/kolla/certificates/haproxy.pem
cp \
  /etc/kolla/certificates/ca/haproxy-internal.crt \
  /etc/kolla/certificates/ca/haproxy.crt

echo '***'
echo '*** copy root ca'
echo '***'
for crt in /usr/local/share/ca-certificates/*.crt; do
  openssl x509 \
    -in $crt \
    -out /etc/kolla/certificates/ca/$(basename $crt)
done

echo '***'
echo '*** generate passwords for kolla'
echo '***'
cat > /etc/kolla/imported_passwords.yml <<EOF
# Merge following secrets with otherwise generated secrets
barbican_crypto_key: ${BARBICAN_KEK}
barbican_database_password: ${BARBICAN_DBPASS}
barbican_keystone_password: ${BARBICAN_PASS}
cinder_database_password: ${CINDER_DBPASS}
cinder_keystone_password: ${CINDER_PASS}
designate_database_password: ${DESIGNATE_DBPASS}
designate_keystone_password: ${DESIGNATE_PASS}
glance_database_password: ${GLANCE_DBPASS}
glance_keystone_password: ${GLANCE_PASS}
keystone_admin_password: ${ADMIN_PASS}
keystone_database_password: ${KEYSTONE_DBPASS}
metadata_secret: ${METADATA_SECRET}
neutron_database_password: ${NEUTRON_DBPASS}
neutron_keystone_password: ${NEUTRON_PASS}
nova_api_database_password: ${NOVA_DBPASS}
nova_database_password: ${NOVA_DBPASS}
nova_keystone_password: ${NOVA_PASS}
octavia_ca_password: ${SSL_OCTAVIA_SERVER_CA_PASSWORD}
octavia_database_password: ${OCTAVIA_DBPASS}
octavia_keystone_password: ${OCTAVIA_PASS}
placement_database_password: ${PLACEMENT_DBPASS}
placement_keystone_password: ${PLACEMENT_PASS}
rabbitmq_password: ${RABBIT_PASS}
EOF
cp -r ${VIRTUAL_ENV}/share/kolla-ansible/etc_examples/kolla/passwords.yml /etc/kolla/generated_passwords.yml
kolla-genpwd --passwords /etc/kolla/generated_passwords.yml
kolla-mergepwd --old /etc/kolla/imported_passwords.yml --new /etc/kolla/generated_passwords.yml --final /etc/kolla/passwords.yml

echo '***'
echo '*** configure globals.yml'
echo '***'
cp -r ${VIRTUAL_ENV}/share/kolla-ansible/etc_examples/kolla/globals.yml /etc/kolla/globals.yml
syv cinder_volume_group "system" /etc/kolla/globals.yml
syv designate_backend "bind9" /etc/kolla/globals.yml
syv designate_ns_record "${OS_DNS_DOMAIN}" /etc/kolla/globals.yml
syv enable_cinder "yes" /etc/kolla/globals.yml
syv enable_cinder_backend_lvm "yes" /etc/kolla/globals.yml
syv enable_designate yes /etc/kolla/globals.yml
syv enable_grafana yes /etc/kolla/globals.yml
syv enable_neutron_provider_networks "yes" /etc/kolla/globals.yml
syv enable_octavia "yes" /etc/kolla/globals.yml
syv enable_prometheus yes /etc/kolla/globals.yml
syv enable_redis "yes" /etc/kolla/globals.yml
syv kolla_base_distro "ubuntu" /etc/kolla/globals.yml
syv kolla_copy_ca_into_containers "yes" /etc/kolla/globals.yml
syv kolla_enable_tls_backend "yes" /etc/kolla/globals.yml
syv kolla_enable_tls_external "yes" /etc/kolla/globals.yml
syv kolla_enable_tls_internal "yes" /etc/kolla/globals.yml
syv kolla_external_fqdn "${HAPROXY_FQDN}" /etc/kolla/globals.yml
syv kolla_external_vip_address "${HAPROXY_IP_ADDRESS}" /etc/kolla/globals.yml
syv kolla_install_type "binary" /etc/kolla/globals.yml
syv kolla_internal_fqdn "${HAPROXY_FQDN}" /etc/kolla/globals.yml
syv kolla_internal_vip_address "${HAPROXY_IP_ADDRESS}" /etc/kolla/globals.yml
syv network_interface "${COMPUTE_MANAGEMENT_PHYSICAL_NIC}" /etc/kolla/globals.yml
syv neutron_external_interface "${COMPUTE_PROVIDER_PHYSICAL_NIC}" /etc/kolla/globals.yml
syv neutron_plugin_agent "ovn" /etc/kolla/globals.yml
syv node_custom_config "/etc/kolla/config" /etc/kolla/globals.yml
syv nova_compute_virt_type "kvm" /etc/kolla/globals.yml
syv octavia_amp_network_cidr "${OCTAVIA_AMP_NETWORK_CIDR}" /etc/kolla/globals.yml
syv openstack_cacert "/etc/ssl/certs/ca-certificates.crt" /etc/kolla/globals.yml
syv openstack_logging_debug "False" /etc/kolla/globals.yml
syv openstack_release "master" /etc/kolla/globals.yml
syv syslog_server "loghost.se.lemche.net" /etc/kolla/globals.yml
syv syslog_udp_port "514" /etc/kolla/globals.yml

# Ceilometer is depending on gnocchi, but its broken atm
# syv enable_ceilometer yes /etc/kolla/globals.yml

# Disabled as Ironic on ubuntu is broken at this time
# syv enable_ironic yes /etc/kolla/globals.yml
# syv ironic_dnsmasq_interface ${IRONIC_DNSMASQ_INTERFACE} /etc/kolla/globals.yml
# syv ironic_dnsmasq_dhcp_range ${IRONIC_DNSMASQ_DHCP_RANGE} /etc/kolla/globals.yml
# syv ironic_cleaning_network ${IRONIC_CLEANING_NETWORK} /etc/kolla/globals.yml
# syv ironic_dnsmasq_default_gateway ${IRONIC_DNSMASQ_DEFAULT_GATEWAY} /etc/kolla/globals.yml

echo '***'
echo '*** check configuration'
echo '***'
grep -v -E "^$|^#" /etc/kolla/globals.yml | sort

echo '***'
echo '*** set specific debug configuration for a given service'
echo '***'
# crudini --set /etc/kolla/config/designate.conf DEFAULT debug True
# crudini --set /etc/kolla/config/neutron.conf DEFAULT debug True
# crudini --set /etc/kolla/config/nova.conf DEFAULT debug True
# crudini --set /etc/kolla/config/keystone.conf DEFAULT debug True

echo '***'
echo '*** create additional cinder volume type configuration'
echo '***'
if [[ ! -d /etc/kolla/config/designate-worker ]]; then mkdir -p /etc/kolla/config/designate-worker; fi
cat <<EOF | sudo tee /etc/kolla/config/designate-worker/pools.yaml
- name: default
  description: Default BIND9 Pool
  attributes: {}
  ns_records:
    - hostname: ${OS_DNS_DOMAIN}.
      priority: 1
  nameservers:
    - host: ${COMPUTE_IP_ADDRESS}
      port: 53
  targets:
    - type: bind9
      description: BIND9 Server ${COMPUTE_IP_ADDRESS}
      masters:
        - host: ${COMPUTE_IP_ADDRESS}
          port: 5354
      options:
        host: ${COMPUTE_IP_ADDRESS}
        port: 53
        rndc_host: ${COMPUTE_IP_ADDRESS}
        rndc_port: 953
        rndc_key_file: /etc/designate/rndc.key
EOF

echo '***'
echo '*** ironic on ubuntu is broken at this time, so we set this manually'
echo '***'
if [[ ! -d /etc/kolla/config/neutron ]]; then mkdir -p /etc/kolla/config/neutron; fi
if [[ -d /etc/kolla/config/neutron/ml2_conf.ini ]]; then rm -f /etc/kolla/config/neutron/ml2_conf.ini; fi
crudini --set /etc/kolla/config/neutron/ml2_conf.ini ml2_type_vlan network_vlan_ranges "${COMPUTE_PROVIDER_VIRTUAL_NIC}"
crudini --set /etc/kolla/config/neutron/ml2_conf.ini ml2_type_flat flat_networks "*"

echo '***'
echo '*** create additional nova allocation configuration'
echo '***'
if [[ -d /etc/kolla/config/nova.conf ]]; then rm -f /etc/kolla/config/nova.conf; fi
crudini --set /etc/kolla/config/nova.conf DEFAULT cpu_allocation_ratio "16.0"
crudini --set /etc/kolla/config/nova.conf DEFAULT ram_allocation_ratio "5.0"
crudini --set /etc/kolla/config/nova.conf DEFAULT disk_allocation_ratio "3"
crudini --set /etc/kolla/config/nova.conf scheduler driver "filter_scheduler"
crudini --set /etc/kolla/config/nova.conf filter_scheduler available_filters "nova".scheduler.filters.all_filters
crudini --set /etc/kolla/config/nova.conf filter_scheduler enabled_filters "AvailabilityZoneFilter, ComputeFilter, ComputeCapabilitiesFilter, ImagePropertiesFilter, ServerGroupAntiAffinityFilter, ServerGroupAffinityFilter"

echo '***'
echo '*** create additional cinder volume type configuration'
echo '***'
if [[ ! -d /etc/kolla/config/cinder ]]; then mkdir -p /etc/kolla/config/cinder; fi
if [[ -d /etc/kolla/config/cinder/cinder-volume.conf ]]; then rm -f /etc/kolla/config/cinder/cinder-volume.conf; fi
crudini --set /etc/kolla/config/cinder/cinder-volume.conf DEFAULT enabled_backends "premium,standard"
crudini --set /etc/kolla/config/cinder/cinder-volume.conf premium volume_group "cinder-premium-vg"
crudini --set /etc/kolla/config/cinder/cinder-volume.conf premium volume_driver "cinder.volume.drivers.lvm.LVMVolumeDriver"
crudini --set /etc/kolla/config/cinder/cinder-volume.conf premium volume_backend_name "premium"
crudini --set /etc/kolla/config/cinder/cinder-volume.conf premium target_helper "tgtadm"
crudini --set /etc/kolla/config/cinder/cinder-volume.conf premium target_protocol "iscsi"
crudini --set /etc/kolla/config/cinder/cinder-volume.conf standard volume_group "cinder-standard-vg"
crudini --set /etc/kolla/config/cinder/cinder-volume.conf standard volume_driver "cinder.volume.drivers.lvm.LVMVolumeDriver"
crudini --set /etc/kolla/config/cinder/cinder-volume.conf standard volume_backend_name "standard"
crudini --set /etc/kolla/config/cinder/cinder-volume.conf standard target_helper "tgtadm"
crudini --set /etc/kolla/config/cinder/cinder-volume.conf standard target_protocol "iscsi"
