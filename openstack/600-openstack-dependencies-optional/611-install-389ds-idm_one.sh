#!/bin/bash

##############################################################################
# Install 389 Directory Server
##############################################################################
# Import configuration data to environment
export ETCDCTL_DISCOVERY_SRV="$(hostname -d)"
if [[ -z ${ETCD_USER_PASS+x} ]]; then echo "Fetch from user password from secret management"; read -s ETCD_USER_PASS; fi
if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read -s ETCD_ADMIN_PASS; fi
source $HOME/prepare-node.env

# Install 389-ds
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes install \
  389-ds \
  crudini

# sudo dsctl ${IDM_INSTANCE_NAME} remove --do-it

# Set /proc/sys values
cat << EOF | sudo tee /etc/sysctl.d/99-389-ds.conf
net.ipv4.tcp_keepalive_time = 300
net.ipv4.ip_local_port_range = 1024 65000
fs.file-max = 64000
EOF
sudo sysctl --load=/etc/sysctl.d/99-389-ds.conf

# Set limits for 389ds runtime user
cat << EOF | sudo tee /etc/security/limits.d/389-ds.conf
dirsrv        -       nofile          8192
EOF

# Create a location to store FreeIPA configuration files
if [[ ! -d ${FREEIPA_CONFIGURATION_DIRECTORY} ]]; then
  sudo mkdir -p ${FREEIPA_CONFIGURATION_DIRECTORY}/
fi
sudo chown root:root ${FREEIPA_CONFIGURATION_DIRECTORY}/
sudo chmod 0750 ${FREEIPA_CONFIGURATION_DIRECTORY}/

# Download IDM_ONE certificate PKCS#12 keystore
etcdctl --username user:$ETCD_USER_PASS get /keystores/IDM_ONE_FQDN \
| tr -d '\n' \
| base64 --decode \
> ~/${IDM_ONE_FQDN}.p12

# Extract IDM certificate and key from keystore
sudo openssl pkcs12 \
  -in ~/${IDM_ONE_FQDN}.p12 \
  -passin pass:${IDM_ONE_KEYSTORE_PASS} \
  -nokeys \
  -clcerts \
| openssl x509 \
| sudo tee ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_ONE_FQDN}.crt
sudo openssl pkcs12 \
  -in ~/${IDM_ONE_FQDN}.p12 \
  -passin pass:${IDM_ONE_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| openssl rsa 2>/dev/null \
| sudo tee ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_ONE_FQDN}.key
sudo chown root:root ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_ONE_FQDN}.key
sudo chmod 0640 ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_ONE_FQDN}.key

# Remove keystore
rm -f ~/${IDM_ONE_FQDN}.p12

# Create instance configuration file
sudo crudini --set ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf general full_machine_name "${IDM_ONE_FQDN}"
sudo crudini --set ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf general selinux "False"
sudo crudini --set ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf general start "True"
sudo crudini --set ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf slapd instance_name "${IDM_INSTANCE_NAME}"
sudo crudini --set ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf slapd root_password "${DS_ROOT_PASS}"
sudo crudini --set ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf slapd self_sign_cert "False"
sudo crudini --set ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf backend-userroot create_suffix_entry "True"
sudo crudini --set ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf backend-userroot sample_entries "yes"
sudo crudini --set ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf backend-userroot suffix "${DS_SUFFIX}"
sudo chown root:root ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf
sudo chmod 0640 ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf

# Create instance from file
sudo dscreate \
  from-file ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_INSTANCE_NAME}.inf

# Import CA certificates to DS keystore
sudo dsctl ${IDM_INSTANCE_NAME} \
  tls import-ca \
    /usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt \
    "${SSL_ROOT_CA_COMMON_NAME}"
sudo dsctl ${IDM_INSTANCE_NAME} \
  tls import-ca \
    /usr/local/share/ca-certificates/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
    "${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME}"
sudo dsctl ${IDM_INSTANCE_NAME} \
  tls list-ca

# Importing a Private Key and Server Certificate
sudo dsctl ${IDM_INSTANCE_NAME} \
  tls import-server-key-cert \
    ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_ONE_FQDN}.crt \
    ${FREEIPA_CONFIGURATION_DIRECTORY}/${IDM_ONE_FQDN}.key
sudo dsctl ${IDM_INSTANCE_NAME} \
  tls show-cert \
    Server-Cert

# Enable StartTLs and LDAPS
sudo dsconf \
  -D "cn=Directory Manager" \
  -w "${DS_ROOT_PASS}" \
  ldap://${IDM_ONE_FQDN}:389 \
  config replace \
    nsslapd-securePort=636 \
    nsslapd-security=on
sudo dsconf \
  -D "cn=Directory Manager" \
  -w "${DS_ROOT_PASS}" \
  ldap://${IDM_ONE_FQDN}:389 \
    security certificate list
sudo dsconf \
  -D "cn=Directory Manager" \
  -w "${DS_ROOT_PASS}" \
  ldap://${IDM_ONE_FQDN}:389 \
  security rsa set \
    --tls-allow-rsa-certificates on \
    --nss-token "internal (software)" \
    --nss-cert-name Server-Cert

# Restart instance
sudo dsctl ${IDM_INSTANCE_NAME} \
  restart

# Check encryption configuration
ldapsearch \
  -H ldap://${IDM_ONE_FQDN}:389 \
  -D 'cn=Directory Manager' \
  -w "${DS_ROOT_PASS}" \
  -Z \
  -b 'cn=encryption,cn=config' \
  -x

# Create UFW configuration for LDAP
sudo ufw allow ldap
sudo ufw allow ldaps
