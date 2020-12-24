#!/bin/sh

if [ "$1" = "" ]; then
    echo '***'
    echo '*** no hostname set as argument, so defaulting to "joxit"'
    echo '***'
    HOSTNAME='joxit'
fi

if [ ! -d /var/lib/joxit ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'data'
    echo '***'
    sudo mkdir -p /var/lib/joxit
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
echo -n '*** creating regitry container name' $HOSTNAME 'with ID '
cat << EOF | sudo tee /var/lib/joxit/docker-compose.yml
$HOSTNAME:
  container_name: $HOSTNAME
  dns_search: se.lemche.net
  hostname: $HOSTNAME
  environment:
    DELETE_IMAGES: "true"
    URL: https://registry.se.lemche.net:5001
  image: joxit/docker-registry-ui:arm64v8
  ports:
    - 192.168.1.52:80:80
  restart: unless-stopped
EOF
(cd /var/lib/joxit/; docker-compose up -d)
echo '***'

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
