#!/bin/sh

if [[ $1 == "" ]]; then
    echo '***'
    echo '*** no hostname set as argument, so defaulting to "registry"'
    echo '***'
    HOSTNAME='registry'
fi

if [ ! -d /var/lib/registry/auth ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'auth data'
    echo '***'
    sudo mkdir -p /var/lib/registry/auth
fi

if [ ! -d /var/lib/registry/certs ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'certificates'
    echo '***'
    sudo mkdir -p /var/lib/registry/certs
fi

if [ ! -d /var/lib/registry/data ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'regitry data'
    echo '***'
    sudo mkdir -p /var/lib/registry/data
fi

echo '***'
echo -n '*** generate password for registry'
PASSWORD=$(apg -m16 -x16 -n1 -MCNL)
echo '***'

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
 httpd \
 -Bbn docker $PASSWORD \
 | sudo tee /var/lib/registry/auth/htpasswd
echo '***'

echo '***'
echo -n '*** removing container named '
docker container rm htpasswd
echo '***'

echo '***'
echo '*** copying SSL certificates to' ${HOSTNAME}
echo '***'
# sudo cp /net/main/srv/common-setup/ssl/cacert.pem /var/lib/docker/registry/certs/example-ca.crt
# sudo cp /net/main/srv/common-setup/ssl/${HOSTNAME}.example.com-cert.pem /var/lib/docker/registry/certs/${HOSTNAME}.example.com.crt
# sudo cp /net/main/srv/common-setup/ssl/${HOSTNAME}.example.com-key.pem /var/lib/docker/registry/certs/${HOSTNAME}.example.com.key
cat /etc/ssl/certs/${HOSTNAME}.se.lemche.net.crt /usr/local/share/ca-certificates/Lemche.NET-CA.crt | sudo tee /var/lib/registry/certs/domain.crt
sudo cp /etc/ssl/private/${HOSTNAME}.se.lemche.net.key /var/lib/registry/certs/domain.key

cat << EOF | sudo tee /var/lib/registry/docker-compose.yml
$HOSTNAME:
  container_name: $HOSTNAME
  dns_search: se.lemche.net
  hostname: $HOSTNAME
  environment:
    REGISTRY_AUTH: htpasswd
    REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
    REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
    REGISTRY_HTTP_ADDR: 0.0.0.0:5001
    REGISTRY_HTTP_HEADERS_ACCESS-CONTROL-ALLOW-ORIGIN: "['*']"
    REGISTRY_HTTP_HEADERS_ACCESS-CONTROL-ALLOW-METHODS: "['HEAD', 'GET', 'OPTIONS', 'DELETE']"
    REGISTRY_HTTP_HEADERS_ACCESS-CONTROL-EXPOSE-HEADERS: "['Docker-Content-Digest']"
    REGISTRY_HTTP_TLS_CERTIFICATE: /certs/domain.crt
    REGISTRY_HTTP_TLS_KEY: /certs/domain.key
    REGISTRY_LOG_LEVEL: info
    REGISTRY_STORAGE_DELETE_ENABLED: "true"
  image: registry:2
  ports:
    - 192.168.1.50:5001:5001
  restart: unless-stopped
  volumes:
    - /var/lib/registry/data:/var/lib/registry
    - /var/lib/registry/certs:/certs:ro
    - /var/lib/registry/auth:/auth:ro
EOF
(cd /var/lib/registry/; docker-compose up -d)

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
 --password $PASSWORD \
 ${HOSTNAME}.se.lemche.net:5001

echo '***'
echo '*** create alias for performing a registry garbage collect on docker' ${HOSTNAME}
echo '***'
cat << EOF | sudo tee /etc/profile.d/docker-register.sh
alias registry-garbage-collect='docker container exec -it '$HOSTNAME' registry garbage-collect /etc/docker/registry/config.yml'
EOF

echo '***'
echo '*** checking that you can push an image to the registry'
echo '***'
docker image tag httpd:latest ${HOSTNAME}.se.lemche.net:5001/httpd:latest
docker push ${HOSTNAME}.se.lemche.net:5001/httpd:latest
​
echo '***'
echo '*** checking that you can pull an image from the registry'
echo '***'
docker image rm httpd:latest ${HOSTNAME}.se.lemche.net:5001/httpd:latest
docker image pull ${HOSTNAME}.se.lemche.net:5001/httpd:latest
docker image rm ${HOSTNAME}.se.lemche.net:5001/httpd:latest
