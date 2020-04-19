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
echo '*** setup cinder vg'
echo '***'
sudo parted --script /dev/${LVM_STANDARD_PV_DEVICE} mklabel gpt
sudo parted --script /dev/${LVM_STANDARD_PV_DEVICE} mkpart primary 0GB 100%
sudo parted --script /dev/${LVM_STANDARD_PV_DEVICE} set 1 lvm on
sudo pvcreate --yes /dev/${LVM_STANDARD_PV_DEVICE}1
sudo vgcreate cinder-volumes /dev/${LVM_STANDARD_PV_DEVICE}1

echo '***'
echo '*** create kolla configuration directory with configuration templates'
echo '***'
if [[ ! -d /etc/kolla ]]; then sudo mkdir -p /etc/kolla; fi
sudo chown $USER:$USER /etc/kolla
cp -r ${VIRTUAL_ENV}/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp ${VIRTUAL_ENV}/share/kolla-ansible/ansible/inventory/* /etc/kolla/

echo '***'
echo '*** import SSL key pair for haproxy'
echo '***'
if [[ ! -d /etc/kolla/certificates/ca ]]; then mkdir -p /etc/kolla/certificates/ca; fi

etcdctl --username user:$ETCD_USER_PASS get /keystores/${HAPROXY_FQDN}.p12 \
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
echo '*** import SSL key pair for backend'
echo '***'
etcdctl --username user:$ETCD_USER_PASS get /keystores/${COMPUTE_FQDN}.p12 \
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
openssl x509 \
  -in /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt \
  -out /etc/kolla/certificates/ca/${SSL_ROOT_CA_STRICT_NAME}.crt

echo '***'
echo '*** generate passwords for kolla'
echo '***'
cat > /etc/kolla/imported_passwords.yml <<EOF
barbican_database_password: ${BARBICAN_DBPASS}
barbican_crypto_key: ${BARBICAN_KEK}
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
placement_database_password: ${PLACEMENT_DBPASS}
placement_keystone_password: ${PLACEMENT_PASS}
rabbitmq_password: ${RABBIT_PASS}
# \${CA_PASSWORD}
# \${COMPUTE_KEYSTORE_PASS}
# \${CONTROLLER_KEYSTORE_PASS}
# \${CORESWITCH_KEYSTORE_PASS}
# \${DASH_DBPASS}
# \${DEMO_PASS}
# \${DS_ADMIN_PASS}
# \${DS_ROOT_PASS}
# \${HAPROXY_KEYSTORE_PASS}
# \${IDM_ONE_KEYSTORE_PASS}
# \${IDM_TWO_KEYSTORE_PASS}
# \${KERBEROS_MASTER_SECRET}
# \${MANAGEMENT_KEYSTORE_PASS}
# \${PKI_ADMIN_PASSWORD}
# \${PKI_BACKUP_PASSWORD}
# \${PKI_CLIENT_DATABASE_PASSWORD}
# \${PKI_CLIENT_PKCS12_PASSWORD}
# \${PKI_CLONE_PKCS12_PASSWORD}
# \${PKI_REPLICATION_PASSWORD}
# \${PKI_SECURITY_DOMAIN_PASSWORD}
# \${PKI_SERVER_DATABASE_PASSWORD}
# \${PKI_TOKEN_PASSWORD}
# \${RABBIT_ADMIN_PASS}
# \${ROOT_DBPASS}
EOF

cp -r ${VIRTUAL_ENV}/share/kolla-ansible/etc_examples/kolla/passwords.yml /etc/kolla/generated_passwords.yml
kolla-genpwd --passwords /etc/kolla/generated_passwords.yml
kolla-mergepwd --old /etc/kolla/imported_passwords.yml --new /etc/kolla/generated_passwords.yml --final /etc/kolla/passwords.yml

echo '***'
echo '*** configure globals.yml'
echo '***'
syv enable_cinder yes /etc/kolla/globals.yml
syv enable_cinder_backend_lvm yes /etc/kolla/globals.yml
syv enable_neutron_provider_networks yes /etc/kolla/globals.yml
syv kolla_base_distro ubuntu /etc/kolla/globals.yml
syv kolla_copy_ca_into_containers yes /etc/kolla/globals.yml
syv kolla_enable_tls_backend yes /etc/kolla/globals.yml
syv kolla_enable_tls_external yes /etc/kolla/globals.yml
syv kolla_enable_tls_internal yes /etc/kolla/globals.yml
syv kolla_external_fqdn ${HAPROXY_FQDN} /etc/kolla/globals.yml
syv kolla_external_vip_address ${HAPROXY_IP_ADDRESS} /etc/kolla/globals.yml
syv kolla_install_type binary /etc/kolla/globals.yml
syv kolla_internal_fqdn ${HAPROXY_FQDN} /etc/kolla/globals.yml
syv kolla_internal_vip_address ${HAPROXY_IP_ADDRESS} /etc/kolla/globals.yml
syv network_interface ${CONTROLLER_MANAGEMENT_PHYSICAL_NIC} /etc/kolla/globals.yml
syv neutron_external_interface ${CONTROLLER_PROVIDER_PHYSICAL_NIC} /etc/kolla/globals.yml
syv neutron_plugin_agent openvswitch /etc/kolla/globals.yml
syv openstack_cacert /etc/ssl/certs/ca-certificates.crt /etc/kolla/globals.yml
syv openstack_release master /etc/kolla/globals.yml

echo '***'
echo '*** check configuration'
echo '***'
grep -v -E "^$|^#" /etc/kolla/globals.yml | sort
