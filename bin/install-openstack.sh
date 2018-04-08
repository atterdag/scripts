#!/bin/sh

##############################################################################
# Remove previous packages on all
##############################################################################
apt-get --yes --purge remove \
  apache2 \
  chrony \
  libvirt0 \
  memcached \
  mysql-common \
  python-castellan \
  python-memcache \
  python-openstack* \
  python-pymysql \
  qemu-kvm \
  qemu-slof \
  qemu-system-common \
  qemu-system-x86 \
  qemu-utils \
  rabbitmq-server \
  sphinx-common \
  tgt
apt-get --yes --purge autoremove
rm -fr \
  /etc/apache2/ \
  /etc/cinder/ \
  /etc/libvirt/ \
  /etc/mysql/ \
  /etc/neutron/ \
  /etc/nova/ \
  /etc/openstack-dashboard/ \
  /etc/openvswitch/ \
  /etc/trafficserver/\
  /var/cache/trafficserver/ \
  /var/lib/libvirt/ \
  /var/lib/nova/ \
  /var/lib/openvswitch/ \
  /var/log/nova/ \
  /var/log/openvswitch/ \
  /var/log/trafficserver/
for i in $(pip list | awk '{print $1}'); do pip uninstall -y $i; done
apt-get --reinstall install $(echo $(dpkg -l | awk '{print $2}' | tail -n +5 | grep ^python-) | sed 's|\n| |g')
##############################################################################

# Install arptables
##############################################################################
apt-get --yes install arptables lvm2 python-pip

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
> os_password.txt
chown root:root os_password.txt
chmod 0600 os_password.txt
source os_password.txt

##############################################################################
# Set OS infrastructure variables
##############################################################################
CONTROLLER_FQDN=etch.se.lemche.net
CONTROLLER_IP_ADDRESS=192.168.1.40
COMPUTE_FQDN=etch.se.lemche.net
COMPUTE_IP_ADDRESS=192.168.1.40
NETWORK_CIDR=192.168.1.0/24
NETWORK_INTERFACE=bond0
LVM_PV_DEVICE=sdc
DNS_DOMAIN=se.lemche.net
SIMPLE_CRYPTO_CA=OpenStack
SSL_CA_NAME=LemcheCA
SSL_COUNTRY_NAME=SE
SSL_STATE=Scania
SSL_ORGANIZATION_NAME=Lemche
SSL_ORGANIZATIONAL_UNIT_NAME=Technical
SSL_BASE_URL=http://ca.example.com/ssl/
SSL_CA_DIR=/var/lib/ssl/${SSL_CA_NAME}

##############################################################################
# Install NTP on Controller host
##############################################################################
apt-get --yes install chrony

mv /etc/chrony/chrony.conf /etc/chrony/chrony.conf.org
cat >> /etc/chrony/chrony.conf << EOT
allow ${NETWORK_CIDR}
EOT
systemctl restart chrony
chmod 0644 /etc/chrony/chrony.conf
chown root:root /etc/chrony/chrony.conf

##############################################################################
# Install NTP on Compute host
##############################################################################
apt-get --yes install chrony

mv /etc/chrony/chrony.conf /etc/chrony/chrony.conf.org
cat > /etc/chrony/chrony.conf << EOT
server ${CONTROLLER_IP_ADDRESS}
EOT
systemctl restart chrony
chmod 0644 /etc/chrony/chrony.conf
chown root:root /etc/chrony/chrony.conf

##############################################################################
# Install OpenStack command line tool on Controller host
##############################################################################
apt-get --yes install python-openstackclient

# pip install python-openstackclient
# pip install python-barbicanclient
# pip install python-ceilometerclient
# pip install python-cinderclient
# pip install python-cloudkittyclient
# pip install python-designateclient
# pip install python-fuelclient
# pip install python-glanceclient
# pip install python-gnocchiclient
# pip install python-heatclient
# pip install python-magnumclient
# pip install python-manilaclient
# pip install python-mistralclient
# pip install python-monascaclient
# pip install python-muranoclient
# pip install python-neutronclient
# pip install python-novaclient
# pip install python-saharaclient
# pip install python-senlinclient
# pip install python-swiftclient
# pip install python-troveclient

##############################################################################
# Install Database on Controller host
##############################################################################
apt-get --yes install mysql-server python-pymysql

cat > /etc/mysql/mariadb.conf.d/99-openstack.cnf << EOF
[mysqld]
bind-address = ${CONTROLLER_IP_ADDRESS}

default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
systemctl restart mysql

##############################################################################
# Install Queue Manager on Controller host
##############################################################################
apt-get --yes install rabbitmq-server

rabbitmqctl add_user openstack $RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

##############################################################################
# Install Memcached on Controller
##############################################################################
apt-get --yes install memcached python-memcache

sed -i "s/^-l\s.*$/-l ${CONTROLLER_IP_ADDRESS}/" /etc/memcached.conf
systemctl restart memcached

##############################################################################
# Install Apache on Controller host
##############################################################################
apt-get --yes install apache2

echo "ServerName ${CONTROLLER_FQDN}" > /etc/apache2/conf-available/servername.conf
a2enconf servername
systemctl reload apache2

##############################################################################
# Install Bind on Controller host
##############################################################################
apt-get install --yes --quiet bind9 bind9utils bind9-doc

rndc-confgen -a -k designate -c /etc/bind/designate.key
chmod 0640 /etc/bind/designate.key
chown bind:bind /etc/bind/designate.key

sed -i 's|^};|\
\tallow-new-zones yes;\
\trequest-ixfr no;\
\tlisten-on port 53 { any; };\
\trecursion no;\
\tallow-query { any; };\
};|' /etc/bind/named.conf.options

cat > /etc/bind/designate.conf << EOF
include "/etc/bind/designate.key";

controls {
  inet 0.0.0.0 port 953
    allow { any; } keys { "designate"; };
};
EOF

cat >> /etc/bind/named.conf.local << EOF
include "/etc/bind/designate.conf";
EOF

systemctl restart bind9

##############################################################################
# Install OpenSSL on Controller host
##############################################################################
apt-get install --yes --quiet openssl

mkdir -p ${SSL_CA_DIR}/{certs,crl,newcerts,private}
chown -R root:ssl-cert ${SSL_CA_DIR}/private
chmod 0750 ${SSL_CA_DIR}/private
sed 's|./demoCA|${SSL_CA_DIR}|g' /etc/ssl/openssl.cnf > ${SSL_CA_DIR}/openssl.cnf
echo "01" > ${SSL_CA_DIR}/serial
echo "01" > ${SSL_CA_DIR}/crlnumber
touch ${SSL_CA_DIR}/index.txt

cat > ${SSL_CA_DIR}/openssl.cnf << EOF
HOME                           = ${SSL_CA_DIR}
RANDFILE                       = ${OPENSSL_CA_DIR}/.rnd
oid_section                    = new_oids

[ new_oids ]
tsa_policy1                    = 1.2.3.4.1
tsa_policy2                    = 1.2.3.4.5.6
tsa_policy3                    = 1.2.3.4.5.7

[ ca ]
default_ca                     = CA_default

[ CA_default ]
dir                            = ${SSL_CA_DIR}
certs                          = \$dir/certs
crl_dir                        = \$dir/crl
database                       = \$dir/index.txt
new_certs_dir                  = \$dir/newcerts
certificate                    = \$dir/cacert.pem
serial                         = \$dir/serial
crlnumber                      = \$dir/crlnumber
crl                            = \$dir/crl.pem
private_key                    = \$dir/private/cakey.pem
RANDFILE                       = \$dir/private/.rand
x509_extensions                = usr_cert
name_opt                       = ca_default
cert_opt                       = ca_default
copy_extensions                = copy
crl_extensions                 = crl_ext
default_days                   = 3650
default_crl_days               = 30
default_md                     = default
preserve                       = no
policy                         = policy_match

[ policy_match ]
countryName                    = match
stateOrProvinceName            = match
organizationName               = match
organizationalUnitName         = optional
commonName                     = supplied
emailAddress                   = optional

[ policy_anything ]
countryName                    = optional
stateOrProvinceName            = optional
localityName                   = optional
organizationName               = optional
organizationalUnitName         = optional
commonName                     = supplied
emailAddress                   = optional

[ req ]
default_bits                   = 4096
default_keyfile                = privkey.pem
distinguished_name             = req_distinguished_name
attributes                     = req_attributes
x509_extensions                = v3_ca
string_mask                    = utf8only
req_extensions                 = v3_req

[ req_distinguished_name ]
countryName                    = Country Name (2 letter code)
countryName_default            = $SSL_COUNTRY_NAME
countryName_min                = 2
countryName_max                = 2
stateOrProvinceName            = State or Province Name (full name)
stateOrProvinceName_default    = $SSL_STATE
localityName                   = Locality Name (eg, city)
0.organizationName             = Organization Name (eg, company)
0.organizationName_default     = $SSL_ORGANIZATION_NAME
organizationalUnitName         = Organizational Unit Name (eg, section)
organizationalUnitName_default = $SSL_ORGANIZATIONAL_UNIT_NAME
commonName                     = Common Name (e.g. server FQDN or YOUR name)
commonName_max                 = 64
emailAddress                   = Email Address
emailAddress_max               = 64

[ req_attributes ]
challengePassword              = A challenge password
challengePassword_min          = 4
challengePassword_max          = 20
unstructuredName               = An optional company name

[ usr_cert ]
basicConstraints=CA:FALSE
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid,issuer
nsBaseUrl                      = ${SSL_BASE_URL}/ca-crl.pem
nsCaRevocationUrl              = ca.crl
nsRevocationUrl                = revocation.html
nsRenewalUrl                   = renewal.html
nsCaPolicyUrl                  = policy.html
issuerAltName                  = URI:${SSL_BASE_URL}/cacert.der
crlDistributionPoints          = URI:${SSL_BASE_URL}/ca.crl
subjectAltName                 = @alt_names

[alt_names]
DNS.1                          = *.${DNS_DOMAIN}
URI.1                          = $SSL_BASE_URL

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage                       = nonRepudiation, digitalSignature, keyEncipherment

[ v3_ca ]
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid:always,issuer:always
basicConstraints               = critical,CA:true
keyUsage                       = cRLSign, keyCertSign
nsCertType                     = sslCA, emailCA
subjectAltName                 = email:copy
issuerAltName                  = issuer:copy
subjectAltName                 = @alt_names

[ crl_ext ]
issuerAltName                  = issuer:copy
authorityKeyIdentifier         = keyid:always

[ proxy_cert_ext ]
basicConstraints               = CA:FALSE
nsCertType                     = server
subjectKeyIdentifier           = hash
authorityKeyIdentifier         = keyid:always,issuer
proxyCertInfo                  = critical,language:id-ppl-anyLanguage,pathlen:3,policy:foo

[ tsa ]
default_tsa                    = tsa_config1

[ tsa_config1 ]
dir                            = ${SSL_CA_DIR}
serial                         = \$dir/tsaserial
crypto_device                  = builtin
signer_cert                    = \$dir/tsacert.pem
certs                          = \$dir/cacert.pem
signer_key                     = \$dir/private/tsakey.pem
signer_digest                  = sha256
default_policy                 = tsa_policy1
other_policies                 = tsa_policy2, tsa_policy3
digests                        = sha1, sha256, sha384, sha512
accuracy                       = secs:1, millisecs:500, microsecs:100
clock_precision_digits         = 0
ordering                       = yes
tsa_name                       = yes
ess_cert_id_chain              = no
EOF

openssl req \
  -config ${SSL_CA_DIR}/openssl.cnf \
  -days 3650 \
  -extensions v3_ca \
  -keyform PEM \
  -keyout ${SSL_CA_DIR}/private/ca.key \
  -new \
  -newkey rsa:4096  \
  -out ${SSL_CA_DIR}/ca.crt \
  -outform PEM \
  -passin pass:${CA_PASSWORD} \
  -passout pass:${CA_PASSWORD} \
  -sha512 \
  -subj "/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${SSL_CA_NAME}" \
  -subject \
  -text \
  -verbose \
  -x509

##############################################################################
# Install Keystone on Controller host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet keystone

systemctl reload apache2

cat > keystone.sql << EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_DBPASS}';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_DBPASS}';
exit
EOF
mysql --user=root --password="${ROOT_DBPASS}" < keystone.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=keystone --password=$KEYSTONE_DBPASS keystone

mv /etc/keystone/keystone.conf /etc/keystone/keystone.conf.org
cat > /etc/keystone/keystone.conf << EOF
[DEFAULT]
log_file = keystone.log
log_dir = /var/log/keystone

[assignment]

[auth]

[cache]

[catalog]
template_file = /etc/keystone/default_catalog.templates

[cors]

[cors.subdomain]

[credential]

[database]
connection = mysql+pymysql://keystone:${KEYSTONE_DBPASS}@${CONTROLLER_FQDN}/keystone

[domain_config]

[endpoint_filter]

[endpoint_policy]

[eventlet_server]

[federation]

[fernet_tokens]

[identity]

[identity_mapping]

[kvs]

[ldap]

[matchmaker_redis]

[memcache]

[oauth1]

[os_inherit]

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[paste_deploy]

[policy]

[profiler]

[resource]

[revoke]

[role]

[saml]

[security_compliance]

[shadow_users]

[signing]

[token]
provider = fernet

[tokenless_auth]

[trust]
EOF
chmod 0640 /etc/keystone/keystone.conf
chown keystone:keystone /etc/keystone/keystone.conf

su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup \
  --keystone-user keystone \
  --keystone-group keystone
keystone-manage credential_setup \
  --keystone-user keystone \
  --keystone-group keystone
keystone-manage bootstrap \
  --bootstrap-password $ADMIN_PASS \
  --bootstrap-admin-url http://${CONTROLLER_FQDN}:35357/v3/ \
  --bootstrap-internal-url http://${CONTROLLER_FQDN}:35357/v3/ \
  --bootstrap-public-url http://${CONTROLLER_FQDN}:5000/v3/ \
  --bootstrap-region-id RegionOne

export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://${CONTROLLER_FQDN}:35357/v3
export OS_IDENTITY_API_VERSION=3

openstack project create \
  --domain default \
  --description "Service Project" \
  service
openstack project create \
  --domain default \
  --description "Demo Project" \
  demo
openstack user create \
  --domain default \
  --password $DEMO_PASS \
  demo
openstack role create \
  user
openstack role add \
  --project demo \
  --user demo \
  user

unset OS_AUTH_URL OS_PASSWORD
openstack \
  --os-auth-url http://${CONTROLLER_FQDN}:35357/v3 \
  --os-project-domain-name Default \
  --os-user-domain-name Default \
  --os-project-name admin \
  --os-username admin token issue \
  --os-password $ADMIN_PASS
openstack \
  --os-auth-url http://${CONTROLLER_FQDN}:35357/v3 \
  --os-project-domain-name Default \
  --os-user-domain-name Default \
  --os-project-name demo \
  --os-username demo token issue \
  --os-password $DEMO_PASS

cat > admin-openrc << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://${CONTROLLER_FQDN}:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
cat > demo-openrc << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=$DEMO_PASS
export OS_AUTH_URL=http://${CONTROLLER_FQDN}:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
source admin-openrc
openstack token issue

##############################################################################
# Install Glance on Controller host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet glance

cat > glance.sql << EOF
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '${GLANCE_DBPASS}';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '${GLANCE_DBPASS}';
exit
EOF
mysql --user=root --password="${ROOT_DBPASS}" < glance.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=glance --password=$GLANCE_DBPASS glance

openstack user create \
  --domain default \
  --password $GLANCE_PASS \
  glance
openstack role add \
  --project service \
  --user glance \
  admin
openstack service create \
  --name glance \
  --description 'OpenStack Image' \
  image
openstack endpoint create \
  --region RegionOne \
  image public http://${CONTROLLER_FQDN}:9292
openstack endpoint create \
  --region RegionOne \
  image internal http://${CONTROLLER_FQDN}:9292
openstack endpoint create \
  --region RegionOne \
  image admin http://${CONTROLLER_FQDN}:9292

mv /etc/glance/glance-api.conf /etc/glance/glance-api.conf.org
cat > /etc/glance/glance-api.conf << EOF
[DEFAULT]

[cors]

[cors.subdomain]

[database]
connection = mysql+pymysql://glance:${GLANCE_DBPASS}@${CONTROLLER_FQDN}/glance

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images

[image_format]

[keystone_authtoken]
auth_uri = http://${CONTROLLER_FQDN}:5000
auth_url = http://${CONTROLLER_FQDN}:35357
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = $GLANCE_PASS
auth_type = password

[matchmaker_redis]

[oslo_concurrency]
lock_path = /var/lock/glance

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_policy]

[paste_deploy]
flavor = keystone

[profiler]

[store_type_location_strategy]

[task]

[taskflow_executor]
EOF
chmod 0640 /etc/glance/glance-api.conf
chown glance:glance /etc/glance/glance-api.conf

mv /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.org
cat > /etc/glance/glance-registry.conf << EOF
[DEFAULT]

[database]
connection = mysql+pymysql://glance:${GLANCE_DBPASS}@${CONTROLLER_FQDN}/glance

[glance_store]
filesystem_store_datadir = /var/lib/glance/images

[keystone_authtoken]
auth_uri = http://${CONTROLLER_FQDN}:5000
auth_url = http://${CONTROLLER_FQDN}:35357
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = $GLANCE_PASS
auth_type = password

[matchmaker_redis]

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_policy]

[paste_deploy]
flavor = keystone

[profiler]
EOF
chmod 0640 /etc/glance/glance-registry.conf
chown glance:glance /etc/glance/glance-registry.conf

su -s /bin/sh -c "glance-manage db_sync" glance

systemctl restart glance-registry
systemctl restart glance-api

wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img

openstack image create "cirros" \
  --file cirros-0.3.4-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public

openstack image list

##############################################################################
# Install Nova on Controller host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  nova-api \
  nova-conductor \
  nova-consoleauth \
  nova-consoleproxy \
  nova-scheduler

cat > nova.sql << EOF
CREATE DATABASE nova_api;
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';
EOF
mysql --user=root --password=${ROOT_DBPASS} < nova.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=nova --password=$NOVA_DBPASS nova_api
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=nova --password=$NOVA_DBPASS nova

openstack user create \
  --domain default \
  --password $NOVA_PASS \
  nova
openstack role add \
  --project service \
  --user nova \
  admin
openstack service create \
  --name nova \
  --description "OpenStack Compute" \
  compute
openstack endpoint create \
  --region RegionOne \
  compute public http://${CONTROLLER_FQDN}:8774/v2.1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  compute internal http://${CONTROLLER_FQDN}:8774/v2.1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  compute admin http://${CONTROLLER_FQDN}:8774/v2.1/%\(tenant_id\)s

mv /etc/nova/nova.conf /etc/nova/nova.conf.org
cat > /etc/nova/nova.conf << EOF
[DEFAULT]
default_floating_pool = ext-nat
my_ip = ${CONTROLLER_IP_ADDRESS}
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
use_neutron = True
pybasedir = /usr/lib/python2.7/dist-packages
bindir = /usr/bin
state_path = /var/lib/nova
firewall_driver = nova.virt.firewall.NoopFirewallDriver
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
auth_strategy = keystone

[api_database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova_api

[barbican]

[cache]

[cells]

[cinder]
os_region_name = RegionOne

[cloudpipe]

[conductor]

[cors]

[cors.subdomain]

[crypto]

[database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova

[ephemeral_storage_encryption]

[glance]
api_servers = http://${CONTROLLER_FQDN}:9292

[guestfs]

[hyperv]

[image_file_url]

[ironic]

[key_manager]

[keystone_authtoken]
auth_uri = http://${CONTROLLER_FQDN}:5000
auth_url = http://${CONTROLLER_FQDN}:35357
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = $NOVA_PASS
auth_type = password

[libvirt]

[matchmaker_redis]

[metrics]

[mks]

[neutron]
url = http://${CONTROLLER_FQDN}:9696
region_name = RegionOne
service_metadata_proxy = True
metadata_proxy_shared_secret = $METADATA_PROXY_SHARED_SECRET
auth_type = password
auth_url = http://${CONTROLLER_FQDN}:35357
project_name = service
project_domain_name = Default
username = neutron
user_domain_name = Default
password = $NEUTRON_PASS

[osapi_v21]

[oslo_concurrency]
lock_path = /var/lock/nova

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[placement]

[placement_database]

[rdp]

[remote_debug]

[serial_console]

[spice]

[ssl]
ca_file = ${SSL_CA_DIR}/ca.crt
cert_file = ${SSL_CA_DIR}/certs/${CONTROLLER_FQDN}.crt
key_file = ${SSL_CA_DIR}/certs/private/${CONTROLLER_FQDN}.key
version = TLSv1_2
ciphers = AES256-SHA256

[trusted_computing]

[upgrade_levels]

[vmware]

[vnc]
vncserver_listen = \$my_ip
vncserver_proxyclient_address = \$my_ip

[workarounds]

[wsgi]

[xenserver]

[xvp]
EOF
chmod 0640 /etc/nova/nova.conf
chown nova:nova /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage db sync" nova

sed -i 's/^NOVA_CONSOLE_PROXY_TYPE=.*/NOVA_CONSOLE_PROXY_TYPE=novnc/' /etc/default/nova-consoleproxy

systemctl restart nova-api
systemctl restart nova-consoleauth
systemctl restart nova-scheduler
systemctl restart nova-conductor
systemctl restart nova-novncproxy

openstack compute service list

##############################################################################
# Install Nova on Compute host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet nova-compute

mv /etc/nova/nova.conf /etc/nova/nova.conf.org
cat > /etc/nova/nova.conf << EOF
[DEFAULT]
default_floating_pool = ext-nat
my_ip = ${COMPUTE_IP_ADDRESS}
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
use_neutron = True
pybasedir = /usr/lib/python2.7/dist-packages
bindir = /usr/bin
state_path = /var/lib/nova
firewall_driver = nova.virt.firewall.NoopFirewallDriver
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
auth_strategy = keystone

[api_database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova_api

[barbican]

[cache]

[cells]

[cinder]
os_region_name = RegionOne

[cloudpipe]

[conductor]

[cors]

[cors.subdomain]

[crypto]

[database]
connection = mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_FQDN}/nova

[ephemeral_storage_encryption]

[glance]
api_servers = http://${CONTROLLER_FQDN}:9292

[guestfs]

[hyperv]

[image_file_url]

[ironic]

[key_manager]

[keystone_authtoken]
auth_uri = http://${CONTROLLER_FQDN}:5000
auth_url = http://${CONTROLLER_FQDN}:35357
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = $NOVA_PASS
auth_type = password

[libvirt]

[matchmaker_redis]

[metrics]

[mks]

[neutron]
url = http://${CONTROLLER_FQDN}:9696
region_name = RegionOne
service_metadata_proxy = True
metadata_proxy_shared_secret = ${METADATA_PROXY_SHARED_SECRET}
auth_type = password
auth_url = http://${CONTROLLER_FQDN}:35357
project_name = service
project_domain_name = Default
username = neutron
user_domain_name = Default
password = ${NEUTRON_PASS}

[osapi_v21]

[oslo_concurrency]
lock_path = /var/lock/nova

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[placement]

[placement_database]

[rdp]

[remote_debug]

[serial_console]

[spice]

[ssl]

[trusted_computing]

[upgrade_levels]

[vmware]

[vnc]
enabled = True
vncserver_listen = \$my_ip
vncserver_proxyclient_address = \$my_ip
novncproxy_base_url = http://${CONTROLLER_FQDN}:6080/vnc_auto.html
xvpvncproxy_base_url=http://${CONTROLLER_FQDN}:6081/console

[workarounds]

[wsgi]

[xenserver]

[xvp]
EOF
chmod 0640 /etc/nova/nova.conf1
chown nova:nova /etc/nova/nova.conf1

modprobe nbd
echo nbd > /etc/modules-load.d/nbd.conf

systemctl restart nova-compute

##############################################################################
# Install Designate on Controller host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  designate

cat > designate.sql << EOF
CREATE DATABASE designate CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON designate.* TO 'designate'@'localhost' IDENTIFIED BY '${DESIGNATE_DBPASS}';
GRANT ALL PRIVILEGES ON designate.* TO 'designate'@'%' IDENTIFIED BY '${DESIGNATE_DBPASS}';
CREATE DATABASE designate_pool_manager CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON designate_pool_manager.* TO 'designate'@'localhost' IDENTIFIED BY '${DESIGNATE_DBPASS}';
GRANT ALL PRIVILEGES ON designate_pool_manager.* TO 'designate'@'%' IDENTIFIED BY '${DESIGNATE_DBPASS}';
EOF
mysql --user=root --password="${ROOT_DBPASS}" < designate.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=designate --password=$DESIGNATE_DBPASS designate
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=designate --password=$DESIGNATE_DBPASS designate_pool_manager

openstack user create \
  --domain default \
  --password $DESIGNATE_PASS \
  designate
openstack role add \
  --project service \
  --user designate \
  admin
openstack service create \
  --name designate \
  --description 'DNS' \
  dns
openstack endpoint create \
  --region RegionOne \
  dns public http://${CONTROLLER_FQDN}:9001/
openstack endpoint create \
  --region RegionOne \
  dns internal  http://${CONTROLLER_FQDN}:9001/
openstack endpoint create \
  --region RegionOne \
  dns admin  http://${CONTROLLER_FQDN}:9001/

mv /etc/designate/designate.conf /etc/designate/designate.conf.org
cat > /etc/designate/designate.conf << EOF
[DEFAULT]
verbose = True
debug = False
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}

[oslo_messaging_rabbit]

[service:central]

[service:api]
listen = 0.0.0.0:9001
auth_strategy = keystone
api_base_uri = http://${CONTROLLER_FQDN}:9001/
enable_api_v1 = True
enabled_extensions_v1 = diagnostics, quotas, reports, sync, touch
enable_api_v2 = True
enabled_extensions_v2 = quotas, reports

[keystone_authtoken]
auth_uri = http://${CONTROLLER_FQDN}:5000
auth_url = http://${CONTROLLER_FQDN}:35357
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = designate
password = $DESIGNATE_PASS
auth_type = password

[cors]

[cors.subdomain]

[service:sink]

[service:mdns]

[service:agent]

[service:producer]

[producer_task:domain_purge]

[producer_task:delayed_notify]

[producer_task:worker_periodic_recovery]

[service:pool_manager]
pool_id = 794ccc2c-d751-44fe-b57f-8894c9f5c842

[service:worker]

[pool_manager_cache:sqlalchemy]
connection = mysql+pymysql://designate:${DESIGNATE_DBPASS}@${CONTROLLER_FQDN}/designate_pool_manager

[pool_manager_cache:memcache]

[network_api:neutron]
timeout = 30
endpoints = RegionOne|http://${CONTROLLER_FQDN}:9696
endpoint_type = publicURL
auth_type = password
auth_url = http://${CONTROLLER_FQDN}:35357
auth_strategy = keystone
project_name = service
project_domain_name = Default
username = neutron
user_domain_name = Default
password = ${DESIGNATE_PASS}
#insecure = False
#ca_certificates_file =


[storage:sqlalchemy]
connection = mysql+pymysql://designate:${DESIGNATE_DBPASS}@${CONTROLLER_FQDN}/designate

[handler:nova_fixed]

[handler:neutron_floatingip]

[backend:agent:bind9]

[backend:agent:knot2]

[backend:agent:djbdns]

[backend:agent:denominator]

[backend:agent:gdnsd]

[backend:agent:msdns]

[oslo_concurrency]

[coordination]

EOF
chmod 0660 /etc/designate/designate.conf
chown designate:designate /etc/designate/designate.conf

su -s /bin/sh -c "designate-manage database sync" designate
su -s /bin/sh -c "designate-manage pool-manager-cache sync" designate

cat > /etc/designate/pools.yaml << EOF
- name: default
  # The name is immutable. There will be no option to change the name after
  # creation and the only way will to change it will be to delete it
  # (and all zones associated with it) and recreate it.
  description: Default Pool

  attributes: {}

  # List out the NS records for zones hosted within this pool
  # This should be a record that is created outside of designate, that
  # points to the public IP of the controller node.
  ns_records:
    - hostname: etch.se.lemche.net.
      priority: 1

  # List out the nameservers for this pool. These are the actual BIND servers.
  # We use these to verify changes have propagated to all nameservers.
  nameservers:
    - host: 127.0.0.1
      port: 53

  # List out the targets for this pool. For BIND there will be one
  # entry for each BIND server, as we have to run rndc command on each server
  targets:
    - type: bind9
      description: BIND9 Server 1

      # List out the designate-mdns servers from which BIND servers should
      # request zone transfers (AXFRs) from.
      # This should be the IP of the controller node.
      # If you have multiple controllers you can add multiple masters
      # by running designate-mdns on them, and adding them here.
      masters:
        - host: 127.0.0.1
          port: 5354

      # BIND Configuration options
      options:
        host: 127.0.0.1
        port: 53
        rndc_host: 127.0.0.1
        rndc_port: 953
        rndc_key_file: /etc/bind/designate.key
EOF

su -s /bin/sh -c "designate-manage pool update" designate

systemctl restart \
  designate-central \
  designate-api \
  designate-agent \
  designate-mdns \
  designate-pool-manager \
  designate-sink \
  designate-zone-manager

##############################################################################
# Install Neutron on Controller host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  neutron-server \
  neutron-linuxbridge-agent \
  neutron-dhcp-agent \
  neutron-metadata-agent \
  neutron-l3-agent

cat > neutron.sql << EOF
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '${NEUTRON_DBPASS}';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '${NEUTRON_DBPASS}';
EOF
mysql --user=root --password="${ROOT_DBPASS}" < neutron.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=neutron --password=$NEUTRON_DBPASS neutron

openstack user create \
  --domain default \
  --password $NEUTRON_PASS \
  neutron
openstack role add \
  --project service \
  --user neutron \
  admin
openstack service create \
  --name neutron \
  --description 'OpenStack Networking' \
  network
openstack endpoint create \
  --region RegionOne \
  network public http://${CONTROLLER_FQDN}:9696
openstack endpoint create \
  --region RegionOne \
  network internal http://${CONTROLLER_FQDN}:9696
openstack endpoint create \
  --region RegionOne \
  network admin http://${CONTROLLER_FQDN}:9696

mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
cat > /etc/neutron/neutron.conf << EOF
[DEFAULT]
nova_metadata_ip = ${CONTROLLER_FQDN}
metadata_proxy_shared_secret = ${METADATA_PROXY_SHARED_SECRET}
auth_strategy = keystone
core_plugin = ml2
service_plugins =
dhcp_agents_per_network = 2
allow_overlapping_ips = True
notify_nova_on_port_status_changes = True
rpc_backend = rabbit
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
auth_strategy = keystone
notify_nova_on_port_status_changes = True
notify_nova_on_port_data_changes = True
dns_domain = ${DNS_DOMAIN}.

[agent]
root_helper = sudo neutron-rootwrap /etc/neutron/rootwrap.conf

[cors]

[cors.subdomain]

[database]
connection = mysql+pymysql://neutron:${NEUTRON_DBPASS}@${CONTROLLER_FQDN}/neutron

[keystone_authtoken]
auth_uri = http://${CONTROLLER_FQDN}:5000
auth_url = http://${CONTROLLER_FQDN}:35357
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = neutron
password = $NEUTRON_PASS
auth_type = password

[matchmaker_redis]

[nova]
auth_url = http://${CONTROLLER_FQDN}:35357
region_name = RegionOne
project_domain_name = Default
project_name = service
user_domain_name = Default
username = nova
password = $NOVA_PASS
auth_type = password

[oslo_concurrency]
lock_path = /var/lock/neutron

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_policy]

[qos]

[quotas]

[ssl]
EOF
chmod 0660 /etc/neutron/neutron.conf
chown neutron:neutron /etc/neutron/neutron.conf

mv /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.org
cat > /etc/neutron/plugins/ml2/ml2_conf.ini << EOF
[DEFAULT]

[ml2]
type_drivers = flat,vlan
tenant_network_types =
mechanism_drivers = linuxbridge
extension_drivers = port_security,dns

[ml2_type_flat]
flat_networks = provider

[ml2_type_geneve]

[ml2_type_gre]

[ml2_type_vlan]
#network_vlan_ranges = provider:1:4094
network_vlan_ranges = provider

[ml2_type_vxlan]

[securitygroup]
enable_security_group = True
enable_ipset = True
EOF

mv /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.org
cat > /etc/neutron/plugins/ml2/linuxbridge_agent.ini << EOF
[DEFAULT]

[agent]

[linux_bridge]
physical_interface_mappings = provider:${NETWORK_INTERFACE}

[securitygroup]
enable_security_group = True
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

[vxlan]
enable_vxlan = False
EOF

mv /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.org
cat > /etc/neutron/dhcp_agent.ini << EOF
[DEFAULT]
interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = True

[AGENT]
EOF

mv /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini.org
cat > /etc/neutron/metadata_agent.ini << EOF
[DEFAULT]
ova_metadata_ip = $CONTROLLER_FQDN
metadata_proxy_shared_secret = $METADATA_PROXY_SHARED_SECRET
[AGENT]

[cache]
EOF
chmod 0640 /etc/neutron/metadata_agent.ini
chown neutron:neutron /etc/neutron/metadata_agent.ini

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

systemctl restart nova-api
systemctl restart neutron-server
systemctl restart neutron-linuxbridge-agent
systemctl restart neutron-dhcp-agent
systemctl restart neutron-metadata-agent

##############################################################################
# Install Neutron on Compute host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet neutron-linuxbridge-agent

mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
cat > /etc/neutron/neutron.conf << EOF
[DEFAULT]
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
auth_strategy = keystone

[agent]

[cors]

[cors.subdomain]

[database]

[keystone_authtoken]
auth_uri = http://${CONTROLLER_FQDN}:5000
auth_url = http://${CONTROLLER_FQDN}:35357
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = neutron
password = $NEUTRON_PASS
auth_type = password

[matchmaker_redis]

[nova]

[oslo_concurrency]
lock_path = /var/lock/neutron

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_policy]

[qos]

[quotas]

[ssl]
EOF
chmod 0660 /etc/neutron/neutron.conf
chown neutron:neutron /etc/neutron/neutron.conf

mv /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.org
cat > /etc/neutron/plugins/ml2/linuxbridge_agent.ini1 << EOF
[DEFAULT]

[agent]

[linux_bridge]
physical_interface_mappings = provider:${NETWORK_INTERFACE}

[securitygroup]
enable_security_group = True
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

[vxlan]
enable_vxlan = False
EOF

systemctl restart nova-compute
systemctl restart neutron-linuxbridge-agent

neutron ext-list
openstack network agent list

##############################################################################
# Install Horizon on Controller host
##############################################################################
DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet openstack-dashboard-apache

mv /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.py.org
cat >  /etc/openstack-dashboard/local_settings.py << EOF
import os
from django.utils.translation import ugettext_lazy as _
from horizon.utils import secret_key
from openstack_dashboard import exceptions
from openstack_dashboard.settings import HORIZON_CONFIG
DEBUG = True
WEBROOT = '/horizon'
ALLOWED_HOSTS = ['*', ]
OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 2,
}
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
LOCAL_PATH = os.path.dirname(os.path.abspath(__file__))
SECRET_KEY = secret_key.generate_or_read_from_file(
    os.path.join("/","var","lib","openstack-dashboard","secret-key", '.secret_key_store'))
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '${CONTROLLER_FQDN}:11211',
    },
}
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
OPENSTACK_HOST = "${CONTROLLER_FQDN}"
OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "_member_"
OPENSTACK_KEYSTONE_BACKEND = {
    'name': 'native',
    'can_edit_user': True,
    'can_edit_group': True,
    'can_edit_project': True,
    'can_edit_domain': True,
    'can_edit_role': True,
}
OPENSTACK_HYPERVISOR_FEATURES = {
    'can_set_mount_point': False,
    'can_set_password': False,
    'requires_keypair': False,
    'enable_quotas': True
}
OPENSTACK_CINDER_FEATURES = {
    'enable_backup': False,
}
OPENSTACK_NEUTRON_NETWORK = {
    'enable_router': False,
    'enable_quotas': False,
    'enable_ipv6': False,
    'enable_distributed_router': False,
    'enable_ha_router': False,
    'enable_lb': False,
    'enable_firewall': False,
    'enable_vpn': False,
    'enable_fip_topology_check': False,
    'profile_support': None,
    'supported_vnic_types': ['*'],
}
OPENSTACK_HEAT_STACK = {
    'enable_user_pass': True,
}
IMAGE_CUSTOM_PROPERTY_TITLES = {
    "architecture": _("Architecture"),
    "kernel_id": _("Kernel ID"),
    "ramdisk_id": _("Ramdisk ID"),
    "image_state": _("Euca2ools state"),
    "project_id": _("Project ID"),
    "image_type": _("Image Type"),
}
IMAGE_RESERVED_CUSTOM_PROPERTIES = []
API_RESULT_LIMIT = 1000
API_RESULT_PAGE_SIZE = 20
SWIFT_FILE_TRANSFER_CHUNK_SIZE = 512 * 1024
INSTANCE_LOG_LENGTH = 35
DROPDOWN_MAX_ITEMS = 30
TIME_ZONE = "UTC"
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'operation': {
            'format': '%(asctime)s %(message)s'
        },
    },
    'handlers': {
        'null': {
            'level': 'DEBUG',
            'class': 'logging.NullHandler',
        },
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
        },
        'operation': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'operation',
        },
    },
    'loggers': {
        'django.db.backends': {
            'handlers': ['null'],
            'propagate': False,
        },
        'requests': {
            'handlers': ['null'],
            'propagate': False,
        },
        'horizon': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'horizon.operation_log': {
            'handlers': ['operation'],
            'level': 'INFO',
            'propagate': False,
        },
        'openstack_dashboard': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'novaclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'cinderclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'keystoneclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'glanceclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'neutronclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'heatclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'ceilometerclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'swiftclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'openstack_auth': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'nose.plugins.manager': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'django': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'iso8601': {
            'handlers': ['null'],
            'propagate': False,
        },
        'scss': {
            'handlers': ['null'],
            'propagate': False,
        },
    },
}
SECURITY_GROUP_RULES = {
    'all_tcp': {
        'name': _('All TCP'),
        'ip_protocol': 'tcp',
        'from_port': '1',
        'to_port': '65535',
    },
    'all_udp': {
        'name': _('All UDP'),
        'ip_protocol': 'udp',
        'from_port': '1',
        'to_port': '65535',
    },
    'all_icmp': {
        'name': _('All ICMP'),
        'ip_protocol': 'icmp',
        'from_port': '-1',
        'to_port': '-1',
    },
    'ssh': {
        'name': 'SSH',
        'ip_protocol': 'tcp',
        'from_port': '22',
        'to_port': '22',
    },
    'smtp': {
        'name': 'SMTP',
        'ip_protocol': 'tcp',
        'from_port': '25',
        'to_port': '25',
    },
    'dns': {
        'name': 'DNS',
        'ip_protocol': 'tcp',
        'from_port': '53',
        'to_port': '53',
    },
    'http': {
        'name': 'HTTP',
        'ip_protocol': 'tcp',
        'from_port': '80',
        'to_port': '80',
    },
    'pop3': {
        'name': 'POP3',
        'ip_protocol': 'tcp',
        'from_port': '110',
        'to_port': '110',
    },
    'imap': {
        'name': 'IMAP',
        'ip_protocol': 'tcp',
        'from_port': '143',
        'to_port': '143',
    },
    'ldap': {
        'name': 'LDAP',
        'ip_protocol': 'tcp',
        'from_port': '389',
        'to_port': '389',
    },
    'https': {
        'name': 'HTTPS',
        'ip_protocol': 'tcp',
        'from_port': '443',
        'to_port': '443',
    },
    'smtps': {
        'name': 'SMTPS',
        'ip_protocol': 'tcp',
        'from_port': '465',
        'to_port': '465',
    },
    'imaps': {
        'name': 'IMAPS',
        'ip_protocol': 'tcp',
        'from_port': '993',
        'to_port': '993',
    },
    'pop3s': {
        'name': 'POP3S',
        'ip_protocol': 'tcp',
        'from_port': '995',
        'to_port': '995',
    },
    'ms_sql': {
        'name': 'MS SQL',
        'ip_protocol': 'tcp',
        'from_port': '1433',
        'to_port': '1433',
    },
    'mysql': {
        'name': 'MYSQL',
        'ip_protocol': 'tcp',
        'from_port': '3306',
        'to_port': '3306',
    },
    'rdp': {
        'name': 'RDP',
        'ip_protocol': 'tcp',
        'from_port': '3389',
        'to_port': '3389',
    },
}
REST_API_REQUIRED_SETTINGS = ['OPENSTACK_HYPERVISOR_FEATURES',
                              'LAUNCH_INSTANCE_DEFAULTS',
                              'OPENSTACK_IMAGE_FORMATS']
ALLOWED_PRIVATE_SUBNET_CIDR = {'ipv4': [], 'ipv6': []}
COMPRESS_OFFLINE=True
EOF

##############################################################################
# Install Cinder on Controller host
##############################################################################

DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet cinder-api cinder-scheduler

cat > cinder.sql << EOF
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$CINDER_DBPASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$CINDER_DBPASS';
EOF
mysql --user=root --password="${ROOT_DBPASS}" < cinder.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=cinder --password=$CINDER_DBPASS cinder

openstack user create \
  --domain default \
  --password $CINDER_PASS \
  cinder
openstack role add \
  --project service \
  --user cinder \
  admin
openstack service create \
  --name cinder \
  --description 'OpenStack Block Storage' \
  volume
openstack service create \
  --name cinderv2 \
  --description 'OpenStack Block Storage' \
  volumev2
openstack endpoint create \
  --region RegionOne \
  volume public http://${CONTROLLER_FQDN}:8776/v1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  volume internal http://${CONTROLLER_FQDN}:8776/v1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  volume admin http://${CONTROLLER_FQDN}:8776/v1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 public http://${CONTROLLER_FQDN}:8776/v2/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 internal http://${CONTROLLER_FQDN}:8776/v2/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  volumev2 admin http://${CONTROLLER_FQDN}:8776/v2/%\(tenant_id\)s

mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf.org
cat > /etc/cinder/cinder.conf << EOF
[DEFAULT]
# enabled_backends = lvm
auth_strategy = keystone
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
my_ip = ${CONTROLLER_IP_ADDRESS}

[BACKEND]

[BRCD_FABRIC_EXAMPLE]

[CISCO_FABRIC_EXAMPLE]

[COORDINATION]

[FC-ZONE-MANAGER]

[KEY_MANAGER]

[barbican]

[cors]

[cors.subdomain]

[database]
connection = mysql+pymysql://cinder:${CINDER_DBPASS}@${CONTROLLER_FQDN}/cinder

[key_manager]

[keystone_authtoken]
auth_uri = http://${CONTROLLER_FQDN}:5000
auth_url = http://${CONTROLLER_FQDN}:35357
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = cinder
password = $CINDER_PASS
auth_type = password

[matchmaker_redis]

[oslo_concurrency]
lock_path = /var/lock/cinder

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[oslo_reports]

[oslo_versionedobjects]

[ssl]

[lvm]
# volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
# volume_group = pkgosvg0
# iscsi_protocol = iscsi
# iscsi_helper = tgtadm
EOF

su -s /bin/sh -c "cinder-manage db sync" cinder

systemctl restart nova-api
systemctl restart cinder-scheduler

##############################################################################
# Install Cinder on Compute host
##############################################################################

pvcreate /dev/${LVM_PV_DEVICE}
vgcreate cinder-volumes /dev/${LVM_PV_DEVICE}

cat > /etc/lvm/lvmlocal.conf << EOF
config {
checks = 1
abort_on_errors = 0
profile_dir = "/etc/lvm/profile"
}
devices {
dir = "/dev"
scan = [ "/dev" ]
obtain_device_list_from_udev = 1
external_device_info_source = "none"
cache_dir = "/run/lvm"
cache_file_prefix = ""
write_cache_state = 1
sysfs_scan = 1
multipath_component_detection = 1
md_component_detection = 1
fw_raid_component_detection = 0
md_chunk_alignment = 1
data_alignment_detection = 1
data_alignment = 0
data_alignment_offset_detection = 1
ignore_suspended_devices = 0
ignore_lvm_mirrors = 1
disable_after_error_count = 0
require_restorefile_with_uuid = 1
pv_min_size = 2048
issue_discards = 0
allow_changes_with_duplicate_pvs = 0
filter = [ "a/sda/", "a/${LVM_PV_DEVICE}/", "r/.*/"]
}
allocation {
maximise_cling = 1
use_blkid_wiping = 1
wipe_signatures_when_zeroing_new_lvs = 1
mirror_logs_require_separate_pvs = 0
cache_pool_metadata_require_separate_pvs = 0
thin_pool_metadata_require_separate_pvs = 0
}
log {
verbose = 0
silent = 0
syslog = 1
overwrite = 0
level = 0
indent = 1
command_names = 0
prefix = "  "
activation = 0
debug_classes = [ "memory", "devices", "activation", "allocation", "lvmetad", "metadata", "cache", "locking", "lvmpolld", "dbus" ]
}
backup {
backup = 1
backup_dir = "/etc/lvm/backup"
archive = 1
archive_dir = "/etc/lvm/archive"
retain_min = 10
retain_days = 30
}
shell {
history_size = 100
}
global {
umask = 077
test = 0
units = "h"
si_unit_consistency = 1
suffix = 1
activation = 1
proc = "/proc"
etc = "/etc"
locking_type = 1
wait_for_locks = 1
fallback_to_clustered_locking = 1
fallback_to_local_locking = 1
locking_dir = "/run/lock/lvm"
prioritise_write_locks = 1
abort_on_internal_errors = 0
detect_internal_vg_cache_corruption = 0
metadata_read_only = 0
mirror_segtype_default = "raid1"
raid10_segtype_default = "raid10"
sparse_segtype_default = "thin"
use_lvmetad = 1
use_lvmlockd = 0
system_id_source = "none"
use_lvmpolld = 1
notify_dbus = 1
}
activation {
checks = 0
udev_sync = 1
udev_rules = 1
verify_udev_operations = 0
retry_deactivation = 1
missing_stripe_filler = "error"
use_linear_target = 1
reserved_stack = 64
reserved_memory = 8192
process_priority = -18
raid_region_size = 512
readahead = "auto"
raid_fault_policy = "warn"
mirror_image_fault_policy = "remove"
mirror_log_fault_policy = "allocate"
snapshot_autoextend_threshold = 100
snapshot_autoextend_percent = 20
thin_pool_autoextend_threshold = 100
thin_pool_autoextend_percent = 20
use_mlockall = 0
monitoring = 1
polling_interval = 15
activation_mode = "degraded"
}
dmeventd {
mirror_library = "libdevmapper-event-lvm2mirror.so"
snapshot_library = "libdevmapper-event-lvm2snapshot.so"
thin_library = "libdevmapper-event-lvm2thin.so"
}
EOF

DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet cinder-volume tgt

mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf.org
cat > /etc/cinder/cinder.conf << EOF
[DEFAULT]
enabled_backends = lvm
volume_group = cinder-volumes

auth_strategy = keystone
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}
my_ip = ${CONTROLLER_IP_ADDRESS}
glance_api_servers = http://${CONTROLLER_FQDN}:9292

[BACKEND]

[BRCD_FABRIC_EXAMPLE]

[CISCO_FABRIC_EXAMPLE]

[COORDINATION]

[FC-ZONE-MANAGER]

[KEY_MANAGER]

[barbican]

[cors]

[cors.subdomain]

[database]
connection = mysql+pymysql://cinder:${CINDER_DBPASS}@${CONTROLLER_FQDN}/cinder

[key_manager]

[keystone_authtoken]
auth_uri = http://${CONTROLLER_FQDN}:5000
auth_url = http://${CONTROLLER_FQDN}:35357
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = cinder
password = $CINDER_PASS
auth_type = password

[matchmaker_redis]

[oslo_concurrency]
lock_path = /var/lock/cinder

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]

[oslo_messaging_zmq]

[oslo_middleware]

[oslo_policy]

[oslo_reports]

[oslo_versionedobjects]

[ssl]

[lvm]
# volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
# volume_group = pkgosvg0
# iscsi_protocol = iscsi
# iscsi_helper = tgtadm
EOF
chmod 0640 /etc/cinder/cinder.conf
chown cinder:cinder /etc/cinder/cinder.conf

systemctl restart tgt
systemctl restart cinder-volume

openstack volume service list

##############################################################################
# Install Barbican on Controller host
##############################################################################

DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
  barbican-api \
  barbican-keystone-listener \
  barbican-worker

cat > barbican.sql << EOF
CREATE DATABASE barbican;
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'localhost' IDENTIFIED BY '${BARBICAN_DBPASS}';
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'%' IDENTIFIED BY '${BARBICAN_DBPASS}';
EOF
mysql --user=root --password="${ROOT_DBPASS}" < barbican.sql
mysqldump --host=${CONTROLLER_FQDN} --port=3306 --user=barbican --password=$BARBICAN_DBPASS barbican

openstack user create \
  --domain default \
  --password $BARBICAN_PASS \
  barbican
openstack role add \
  --project service \
  --user barbican \
  admin
openstack role create \
  creator
openstack role add \
  --project service \
  --user barbican \
  creator
openstack service create \
  --name barbican \
  --description "Key Manager" \
  key-manager
openstack endpoint create \
  --region RegionOne \
  key-manager public http://${CONTROLLER_FQDN}:9311/v1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  key-manager internal http://${CONTROLLER_FQDN}:9311/v1/%\(tenant_id\)s
openstack endpoint create \
  --region RegionOne \
  key-manager admin http://${CONTROLLER_FQDN}:9311/v1/%\(tenant_id\)s

mv /etc/barbican/barbican.conf /etc/barbican/barbican.conf.org
cat > /etc/barbican/barbican.conf << EOF
[DEFAULT]
bind_host = 0.0.0.0
bind_port = 9311
host_href = http://${CONTROLLER_FQDN}:9311
backlog = 4096
max_allowed_secret_in_bytes = 10000
max_allowed_request_size_in_bytes = 1000000
sql_connection = mysql+pymysql://barbican:${BARBICAN_DBPASS}@${CONTROLLER_FQDN}/barbican
sql_idle_timeout = 3600
default_limit_paging = 10
max_limit_paging = 100
transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_FQDN}

[oslo_messaging_rabbit]

[oslo_messaging_notifications]

[oslo_policy]
policy_file=/etc/barbican/policy.json
policy_default_rule=default

[queue]
enable = False
namespace = 'barbican'
topic = 'barbican.workers'
version = '1.1'
server_name = 'barbican.queue'
asynchronous_workers = 1

[retry_scheduler]
initial_delay_seconds = 10.0
periodic_interval_max_seconds = 10.0

[quotas]
quota_secrets = -1
quota_orders = -1
quota_containers = -1
quota_consumers = -1
quota_cas = -1

[keystone_authtoken]
auth_uri = http://${CONTROLLER_FQDN}:5000
auth_url = http://${CONTROLLER_FQDN}:35357
region_name = RegionOne
memcached_servers = ${CONTROLLER_FQDN}:11211
project_domain_name = Default
user_domain_name = Default
project_name = service
username = barbican
password = $BARBICAN_PASS
auth_type = password

[keystone_notifications]
enable = True
control_exchange = 'openstack'
topic = 'notifications'
allow_requeue = False
version = '1.0'
thread_pool_size = 10

[secretstore]
namespace = barbican.secretstore.plugin
enabled_secretstore_plugins = store_crypto

[crypto]
namespace = barbican.crypto.plugin
enabled_crypto_plugins = simple_crypto

[simple_crypto_plugin]
kek = '${BARBICAN_KEK}'

[dogtag_plugin]

[p11_crypto_plugin]

[kmip_plugin]

[certificate]
namespace = barbican.certificate.plugin
enabled_certificate_plugins = simple_certificate
enabled_certificate_plugins = ${SIMPLE_CRYPTO_CA}_ca

[certificate_event]
namespace = barbican.certificate.event.plugin
enabled_certificate_event_plugins = simple_certificate_event

[${SIMPLE_CRYPTO_CA}_ca_plugin]
ca_cert_path = /etc/barbican/${SIMPLE_CRYPTO_CA}-ca.crt
ca_cert_key_path = /etc/barbican/${SIMPLE_CRYPTO_CA}-ca.key
ca_cert_chain_path = /etc/barbican/${SIMPLE_CRYPTO_CA}-ca.chain
ca_cert_pkcs7_path = /etc/barbican/${SIMPLE_CRYPTO_CA}-ca.p7b
subca_cert_key_directory=/etc/barbican/${SIMPLE_CRYPTO_CA}-cas

[cors]

[cors.subdomain]

EOF
chmod 0640 /etc/barbican/barbican.conf
chown barbican:barbican /etc/barbican/barbican.conf

su -s /bin/sh -c "barbican-manage db_sync" barbican

systemctl restart openstack-barbican-api

##############################################################################
# Bash completion on Controller host
##############################################################################
source admin-openrc
openstack complete | sudo tee /etc/bash_completion.d/osc.bash_completion > /dev/null
source /etc/bash_completion

##############################################################################
# Create VLAN network on Controller host
##############################################################################
source admin-openrc
openstack network create \
  --enable \
  --provider-network-type vlan \
  --provider-physical-network provider \
  --provider-segment 2048 \
  servers
openstack network create \
  --enable \
  --provider-network-type vlan \
  --provider-physical-network provider \
  --provider-segment 3072 \
  dmz

##############################################################################
# Create subnets for VLANs on Controller host
##############################################################################
openstack subnet create \
  --allocation-pool start=172.16.0.20,end=172.16.0.40 \
  --dhcp \
  --dns-nameserver 172.16.0.67 \
  --dns-nameserver 172.16.0.69 \
  --gateway 172.16.0.254 \
  --network servers \
  --subnet-range 172.16.0.0/24 \
  servers
openstack subnet create \
  --allocation-pool start=10.0.0.10,end=10.0.0.128 \
  --dns-nameserver 172.16.0.67 \
  --dns-nameserver 172.16.0.69 \
  --gateway 10.0.0.254 \
  --network dmz \
  --no-dhcp \
  --subnet-range 10.0.0.0/24 \
  dmz

##############################################################################
# Create a fixed IP ports on Controller host
##############################################################################
source admin-openrc
openstack port create \
  --fixed-ip ip-address=172.16.0.30 \
  --network servers \
  debian_servers
openstack port create \
  --fixed-ip ip-address=10.0.0.30 \
  --network dmz \
  debian_dmz

##############################################################################
# Create default SSH key on Controller host
##############################################################################
echo | ssh-keygen -q -N ""
openstack keypair create \
  --public-key ~/.ssh/id_rsa.pub \
  default

##############################################################################
# Create default security on Controller host
##############################################################################
source admin-openrc
openstack security group rule create \
  --proto icmp \
  default
openstack security group rule create \
  --proto tcp \
  --dst-port 22 \
  default

##############################################################################
# Create Debian Jessie amd64 images on Controller host
##############################################################################
apt-get --yes install openstack-debian-images
# add packages
# qemu-guest-agent
# cloud-init

ROOT_PASSWORD=$(apg -m 8 -q -n 1 -a 1 -M NCL)
build-openstack-debian-image \
  --release jessie \
  --minimal \
  --password $ROOT_PASSWORD \
  --architecture amd64
DEBIAN_IMAGE=$(ls -1 debian-jessie-*-amd64.qcow2 | tail -1)
echo $ROOT_PASSWORD > $(echo $DEBIAN_IMAGE | sed 's/\.qcow2/.rootpw/')

source admin-openrc
openstack image create \
  --file $DEBIAN_IMAGE \
  --disk-format qcow2 --container-format bare \
  --public \
  debian-8-openstack-amd64

##############################################################################
# Create debian-stretch-amd64 images on Controller host
##############################################################################
# Ref https://docs.openstack.org/image-guide/obtain-images.html
wget http://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2

source admin-openrc
openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file debian-9-openstack-amd64.qcow2 \
  debian-9-openstack-amd64

##############################################################################
# Create flavor to support debian-jessie-amd64 images on Controller host
##############################################################################
source admin-openrc
openstack flavor create \
  --vcpus 2 \
  --ram 512 \
  --disk 5 \
  m1.medium

##############################################################################
# List prerequisite resources for creating a server instance on Controller host
##############################################################################
source admin-openrc
openstack keypair list
openstack flavor list
openstack image list
openstack network list
openstack port list
openstack security group list

##############################################################################
# Create debian server instance on Controller host
##############################################################################
source admin-openrc
openstack server create \
  --flavor m1.medium \
  --image debian-9-openstack-amd64 \
  --key-name default \
  --nic net-id=servers \
  --security-group default \
  debian9

openstack server create \
  --flavor m1.medium \
  --image debian-9-openstack-amd64 \
  --key-name default \
  --nic port-id=debian_servers \
  --nic port-id=debian_dmz \
  --security-group default \
  debian

##############################################################################
# Get URL for connecting to server instance on Controller host
##############################################################################
source admin-openrc
openstack console url show \
  debian9

##############################################################################
# Attach ports with fixed IP to server instance on Controller host
##############################################################################
source admin-openrc
nova interface-attach --port-id debian_dmz debian
nova interface-attach --port-id debian_servers debian

##############################################################################
# Server instance on Controller host
##############################################################################
source demo-openrc
echo | ssh-keygen -q -N ""
openstack keypair create \
  --public-key ~/.ssh/id_rsa.pub \
  mykey
openstack security group rule create \
  --proto icmp \
  default
openstack security group rule create \
  --proto tcp \
  --dst-port 22 \
  default
openstack keypair list
openstack flavor list
openstack image list
openstack network list
openstack port list
openstack security group list
openstack port create \
  --fixed-ip ip-address=172.16.0.20 \
  --network servers \
  cirros
openstack server create \
  --flavor m1.nano \
  --image cirros \
  --nic port-id=cirros \
  --security-group default \
  --key-name mykey \
  cirros
openstack server list
openstack console url show cirros
