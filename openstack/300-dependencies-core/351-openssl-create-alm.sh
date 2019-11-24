#!/bin/bash

##############################################################################
# Create controller key pair on Controller host
##############################################################################
# Generate controller node key, and certifiate
# sudo openssl ca \
#   -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
#   -revoke ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${ALM_FQDN}.crt \
#   -passin "pass:${CA_PASSWORD}"
export ETCDCTL_ENDPOINTS="http://${CONTROLLER_FQDN}:2379"
etcdctl mk variables/ALM_HOST_NAME 'alm'
etcdctl mk variables/ALM_IP_ADDRESS '192.168.0.42'
etcdctl mk variables/ALM_FQDN "$(etcdctl get variables/ALM_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/AWX_HOST_NAME 'awx'
etcdctl mk variables/AWX_FQDN "$(etcdctl get variables/AWX_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/GOGS_HOST_NAME 'gogs'
etcdctl mk variables/GOGS_FQDN "$(etcdctl get variables/GOGS_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/JENKINS_HOST_NAME 'jenkins'
etcdctl mk variables/JENKINS_FQDN "$(etcdctl get variables/JENKINS_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/JOXIT_HOST_NAME 'joxit'
etcdctl mk variables/JOXIT_FQDN "$(etcdctl get variables/JOXIT_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"
etcdctl mk variables/REGISTRY_HOST_NAME 'registry'
etcdctl mk variables/REGISTRY_FQDN "$(etcdctl get variables/REGISTRY_HOST_NAME).$(etcdctl get variables/DNS_DOMAIN)"

export VAULT_ADDR="https://${CONTROLLER_FQDN}:8200"
vault login -method=userpass username=admin password=$(cat ~/.VAULT_ADMIN_PASS)
vault kv put passwords/ALM_KEYSTORE_PASS value=$(genpasswd 16)

echo "Set environment variables"
for key in $(etcdctl ls variables/ | sed 's|^/variables/||'); do
	export eval $key="$(etcdctl get variables/$key)"
done

echo "Create variables with secrets"
vault login -method=userpass username=user password=$(cat ~/.VAULT_USER_PASS)
for secret in $(vault kv list -format yaml passwords/ | sed 's/^-\s//'); do
	export eval $secret="$(vault kv get -field=value passwords/$secret)"
done

sudo su -c "openssl req \
  -batch \
  -config <(cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf; \
    printf \"[SAN]\nsubjectAltName=DNS:${ALM_FQDN},DNS:${AWX_FQDN},DNS:${GOGS_FQDN},DNS:${JENKINS_FQDN},DNS:${JOXIT_FQDN},DNS:${REGISTRY_FQDN}\") \
  -keyout ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${ALM_FQDN}.key \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${ALM_FQDN}.csr \
  -reqexts SAN \
  -sha256 \
  -subj \"/C=${SSL_COUNTRY_NAME}/ST=${SSL_STATE}/O=${SSL_ORGANIZATION_NAME}/OU=${SSL_ORGANIZATIONAL_UNIT_NAME}/CN=${ALM_FQDN}\" \
  -subject \
  -utf8"

sudo openssl ca \
  -batch \
  -cert ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.crt \
  -config ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/openssl.cnf \
  -days 365 \
  -extensions server_cert \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/reqs/${ALM_FQDN}.csr \
  -keyfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}.key \
  -keyform PEM \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${ALM_FQDN}.crt \
  -passin pass:${CA_PASSWORD}

# Convert PKCS#12 database with the controller keypair
sudo openssl pkcs12 \
  -caname "${SSL_INTERMEDIATE_CA_ONE_COMMON_NAME}" \
  -caname "${SSL_ROOT_CA_COMMON_NAME}" \
  -certfile ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${SSL_ORGANIZATION_NAME}_CA_Chain.crt \
  -export \
  -in ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${ALM_FQDN}.crt \
  -inkey ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/private/${ALM_FQDN}.key \
  -name ${ALM_FQDN} \
  -out ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${ALM_FQDN}.p12 \
  -passout "pass:${ALM_KEYSTORE_PASS}"

# Upload PKCS#12 keystore to vault
vault login -method=userpass username=admin password=$(cat ~/.VAULT_ADMIN_PASS)
sudo cat ${SSL_BASE_DIR}/${SSL_INTERMEDIATE_CA_ONE_STRICT_NAME}/certs/${ALM_FQDN}.p12 \
| base64 \
| vault kv put keystores/${ALM_FQDN}.p12 data=-
