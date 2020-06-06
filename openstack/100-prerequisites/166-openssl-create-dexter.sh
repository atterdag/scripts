#!/bin/bash

##############################################################################
# Create controller key pair on Controller host
##############################################################################
export ETCDCTL_ENDPOINTS="https://${ETCD_ONE_FQDN}:2379"

if [[ -z ${ETCD_ADMIN_PASS+x} ]]; then echo "Fetch from admin password from secret management"; read ETCD_ADMIN_PASS; fi

# Set HA-Proxy server details
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DEXTER_HOST_NAME 'dexter'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DEXTER_FQDN "$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DEXTER_HOST_NAME).$(etcdctl --username admin:"$ETCD_ADMIN_PASS" get /variables/DNS_DOMAIN)"
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /variables/DEXTER_IP_ADDRESS '192.168.1.3'
etcdctl --username admin:"$ETCD_ADMIN_PASS" set /passwords/DEXTER_KEYSTORE_PASS $(genpasswd 16)

# Set environment variables
for key in $(etcdctl ls /variables/ | sed 's|^/variables/||'); do
	export eval $key="$(etcdctl get /variables/$key)"
done

# Get read privileges to etcd
if [[ -z ${ETCD_USER_PASS+x} ]]; then echo "Fetch from user password from secret management"; read ETCD_USER_PASS; fi

# Create variables with secrets
for secret in $(etcdctl --username user:$ETCD_USER_PASS ls /passwords/ | sed 's|^/passwords/||'); do
	export eval $secret="$(etcdctl --username user:$ETCD_USER_PASS get /passwords/$secret)"
done

# Revoke certificate if existing
if [[ -f ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${DEXTER_FQDN}.crt ]]; then
	sudo openssl ca \
	  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
	  -revoke ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${DEXTER_FQDN}.crt \
	  -passin "pass:${CA_PASSWORD}"
fi

sudo su -c "openssl req \
  -batch \
  -config <(cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf; \
    printf \"[SAN]\nsubjectAltName=DNS:${DEXTER_FQDN},IP:${DEXTER_IP_ADDRESS}\") \
  -keyout ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${DEXTER_FQDN}.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${DEXTER_FQDN}.csr \
  -reqexts SAN \
  -sha256 \
  -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${DEXTER_FQDN}\" \
  -subject \
  -utf8"

sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -days 365 \
  -extensions server_cert \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${DEXTER_FQDN}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${DEXTER_FQDN}.crt \
  -passin pass:${CA_PASSWORD}

# Convert PKCS#12 database with the controller keypair
sudo openssl pkcs12 \
  -caname "${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME}" \
  -caname "${SSL_ROOT_CA_COMMON_NAME}" \
  -certfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
  -export \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${DEXTER_FQDN}.crt \
  -inkey ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${DEXTER_FQDN}.key \
  -name ${DEXTER_FQDN} \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${DEXTER_FQDN}.p12 \
  -passout "pass:${DEXTER_KEYSTORE_PASS}"

# Upload PKCS#12 keystore to etcd
sudo cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${DEXTER_FQDN}.p12 \
| base64 \
| etcdctl --username admin:"$ETCD_ADMIN_PASS" set /keystores/${DEXTER_FQDN}.p12
