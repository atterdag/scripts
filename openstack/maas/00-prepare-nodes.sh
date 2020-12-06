#!/bin/bash

echo '***'
echo '*** Remove all packages installed since baseline'
echo '***'
if [[ -f baseline_packages.txt ]]; then
  # Get current packages installed
  dpkg --list \
  | grep ^ii \
  | awk '{print $2}' \
  > new_packages.txt

  # Remove new packages installed since baseline_packages.txt was created
  sudo apt-get --purge --yes --quiet remove \
    $(cat baseline_packages.txt new_packages.txt | sort | uniq -u | tr '\n' ' ')
fi

echo '***'
echo '*** You need to set the most basic variables'
echo '***'
export SSL_ROOT_CA_FQDN=ca.se.lemche.net
export ROOT_DNS_DOMAIN=se.lemche.net
if [[ -z ${ETCD_USER_PASS+x} ]]; then echo "Fetch from user password from secret management"; read -s ETCD_USER_PASS; fi

echo '***'
echo '*** install tools required to fetch variables, secrets and keystores'
echo '***'
sudo apt-get --yes --quiet install \
  ca-certificates \
  etcd-client \
  html2text \
  ssl-cert

echo '***'
echo '*** get list of CA certifiates'
echo '***'
CA_CERTIFICATES=$(curl \
  --silent \
	http://${SSL_ROOT_CA_FQDN}/ \
| html2text \
| grep .crt \
| awk '{print $3}')

echo '***'
echo '*** download each CA certificate'
echo '***'
for ca_certificate in $CA_CERTIFICATES; do
	sudo curl \
	  --output /usr/local/share/ca-certificates/${ca_certificate} \
		--silent \
	  http://${SSL_ROOT_CA_FQDN}/${ca_certificate}
done

echo '***'
echo '*** update OS truststore'
echo '***'
sudo update-ca-certificates \
  --verbose \
  --fresh

echo '***'
echo '*** create and load script to import openstack configuration'
echo '***'
cat > $HOME/prepare-node.env << EOF
##############################################################################
# Getting the environment up for a node
##############################################################################
if [[ ! \$0 =~ bash ]]; then
 echo "You cannot _run_ this script, you have to *source* it."
 exit 1
fi

# Get read privileges to etcd
if [[ -z \${ETCD_USER_PASS+x} ]]; then
  echo "ETCD_USER_PASS is undefined, run the following to set it"
  echo 'echo "Fetch from user password from secret management"; read -s ETCD_USER_PASS'
  return 1
fi

export ETCDCTL_DISCOVERY_SRV="$ROOT_DNS_DOMAIN"

# Create variables with infrastructure configuration
for key in \$(etcdctl ls /variables/ | sed 's|^/variables/||'); do
    export eval \$key="\$(etcdctl get /variables/\$key)"
done

# Create variables with secrets
for secret in \$(etcdctl --username user:\$ETCD_USER_PASS ls /passwords/ | sed 's|^/passwords/||'); do
    export eval \$secret="\$(etcdctl --username user:\$ETCD_USER_PASS get /passwords/\$secret)"
done
EOF
source $HOME/prepare-node.env

echo '***'
echo '*** determine'
echo '***'
HOST_NAME=$(hostname -s)
HOST_IP=$(hostname -i)
HOST_FQDN=${HOST_NAME}.${ROOT_DNS_DOMAIN}
CONTEXT=$(hostname | tr '[:lower:]' '[:upper:]')
eval CONTEXT_KEYSTORE_PASS=\$${CONTEXT}_KEYSTORE_PASS

echo '***'
echo '*** ensure /etc/hosts is configured correctly'
echo '***'
if ! grep ${HOST_FQDN} /etc/hosts > /dev/null; then
  echo -e "${HOST_IP}\t${HOST_FQDN}\t${HOST_NAME}" \
  |  sudo tee -a /etc/hosts
fi
if grep ^127.0.1.1 /etc/hosts > /dev/null; then
  sudo sed -i 's|^127.0.1.1|#127.0.1.1|' /etc/hosts
fi

echo '***'
echo '*** retrieve and install host FQDN certificate'
echo '***'
etcdctl --username user:$ETCD_USER_PASS get /keystores/${CONTEXT}.p12 \
| tr -d '\n' \
| base64 --decode \
> ${HOST_FQDN}.p12

openssl pkcs12 \
  -in ${HOST_FQDN}.p12 \
  -passin pass:${CONTEXT_KEYSTORE_PASS} \
  -nokeys \
| sudo tee /etc/ssl/certs/${HOST_FQDN}.crt

openssl pkcs12 \
  -in ${HOST_FQDN}.p12 \
  -passin pass:${CONTEXT_KEYSTORE_PASS} \
  -nocerts \
  -nodes \
| sudo tee /etc/ssl/private/${HOST_FQDN}.key

sudo chown root:ssl-cert \
  /etc/ssl/certs/${HOST_FQDN}.crt \
  /etc/ssl/private/${HOST_FQDN}.key

sudo chmod 644 /etc/ssl/certs/${HOST_FQDN}.crt
sudo chmod 640 /etc/ssl/private/${HOST_FQDN}.key

rm -f ${HOST_FQDN}.p12
