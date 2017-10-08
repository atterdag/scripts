#!/bin/sh

if [ "$1" = "" ]; then
    echo '***'
    echo '*** no hostname set as argument, so defaulting to "registry"'
    echo '***'
    HOSTNAME='registry'
fi

if [ ! -d /var/lib/docker/registry/auth ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'auth data'
    echo '***'
    sudo mkdir -p /var/lib/docker/registry/auth
fi

if [ ! -d /var/lib/docker/registry/certs ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'certificates'
    echo '***'
    sudo mkdir -p /var/lib/docker/registry/certs
fi

echo '***'
echo -n '*** stopping previous container named '
docker container stop $HOSTNAME
echo '***'

echo '***'
echo -n '*** removing previous container named '
docker container rm $HOSTNAME
echo '***'

echo '***'
echo '*** generating htpasswd for' ${HOSTNAME}
docker container run \
 --name htpasswd \
 --entrypoint htpasswd \
 registry:2 \
 -Bbn docker passw0rd \
 | sudo tee /var/lib/docker/registry/auth/htpasswd
echo '***'

echo '***'
echo -n '*** removing container named '
docker container rm htpasswd
echo '***'

echo '***'
echo '*** copying SSL certificates to' ${HOSTNAME}
echo '***'
sudo cp /net/main/srv/common-setup/ssl/cacert.pem /var/lib/docker/registry/certs/example-ca.crt
sudo cp /net/main/srv/common-setup/ssl/${HOSTNAME}.example.com-cert.pem /var/lib/docker/registry/certs/${HOSTNAME}.example.com.crt
sudo cp /net/main/srv/common-setup/ssl/${HOSTNAME}.example.com-key.pem /var/lib/docker/registry/certs/${HOSTNAME}.example.com.key

echo '***'
echo -n '*** creating regitry container name' $HOSTNAME 'with ID '
docker container run \
 --detach \
 --dns-search=example.com \
 --env="REGISTRY_HTTP_HEADERS_ACCESS-CONTROL-ALLOW-ORIGIN=['*']" \
 --env="REGISTRY_HTTP_HEADERS_ACCESS-CONTROL-ALLOW-METHODS=['HEAD', 'GET', 'OPTIONS', 'DELETE']" \
 --env="REGISTRY_HTTP_HEADERS_ACCESS-CONTROL-EXPOSE-HEADERS=['Docker-Content-Digest']" \
 --env="REGISTRY_LOG_LEVEL=debug" \
 --env="REGISTRY_STORAGE_DELETE_ENABLED=true" \
 --hostname=${HOSTNAME}.example.com \
 --init \
 --interactive \
 --name=$HOSTNAME \
 --network=bridge \
 --publish 5000:5000 \
 --restart=always \
 --tmpfs /tmp \
 --tty \
 --volume=/var/lib/docker/registry:/var/lib/registry \
 --volume=/var/lib/docker/registry/certs:/var/data/certs:ro \
 --volume=/var/lib/docker/registry/auth:/var/data/auth/:ro \
 registry:2
echo '***'
# I can't create certificates that gnutls accepts, so I have to leave the registry traffic unencrypted
 # --env="REGISTRY_AUTH=htpasswd" \
 # --env="REGISTRY_AUTH_HTPASSWD_PATH=/var/data/auth/htpasswd" \
 # --env="REGISTRY_AUTH_HTPASSWD_REALM=Example Docker Images Realm" \
 # --env="REGISTRY_HTTP_HEADERS_ACCESS-CONTROL-ALLOW-CREDENTIALS=[true]" \
 # --env "REGISTRY_HTTP_TLS_CERTIFICATE=/var/data/certs/${HOSTNAME}.example.com.crt" \
 # --env "REGISTRY_HTTP_TLS_KEY=/var/data/certs/${HOSTNAME}.example.com.key" \
 # --env "REGISTRY_HTTP_TLS_CLIENTCAS= - /var/data/certs/example-ca.crt" \
 # --env="REGISTRY_HTTP_HEADERS_ACCESS-CONTROL-ALLOW-HEADERS=['Authorization']" \
 # --env="REGISTRY_HTTP_SECRET=passw0rd" \

sleep 1

echo '***'
echo '*** checking if container is running'
echo '***'
docker container ps \
 --all \
 --filter name=$HOSTNAME

echo '***'
echo '*** checking log from container'
echo '***'
docker container logs \
 --details \
 --timestamps \
 $HOSTNAME

echo '***'
echo '*** checking that you can login'
echo '***'
docker login \
 --username docker \
 --password passw0rd \
 ${HOSTNAME}.example.com:5000

# docker service create \
  # --name registry \
  # --secret domain.crt \
  # --secret domain.key \
  # --label registry=true \
  # -v /mnt/registry:/var/lib/registry \
  # -e REGISTRY_HTTP_ADDR=0.0.0.0:80 \
  # -e REGISTRY_HTTP_TLS_CERTIFICATE=/run/secrets/domain.crt \
  # -e REGISTRY_HTTP_TLS_KEY=/run/secrets/domain.key \
  # -p 80:80 \
  # --replicas 1 \
  # registry:2

echo '***'
echo '*** create alias for performing a registry garbage collect on docker registry'
echo '***'
cat << EOF | sudo tee /etc/profile.d/docker-register.sh
alias registry-garbage-collect='docker container exec -it registry registry garbage-collect /etc/docker/registry/config.yml'
EOF
