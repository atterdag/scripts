#!/bin/sh

if [[ $1 == "" ]]; then
    echo '***'
    echo '*** no hostname set as argument, so defaulting to "gogs"'
    echo '***'
    HOSTNAME='gogs'
fi

if [ ! -d /var/lib/alm ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'data'
    echo '***'
    sudo mkdir -p /var/lib/alm
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
cat << EOF | sudo tee /var/lib/alm/docker-compose.yml
$HOSTNAME:
  container_name: $HOSTNAME
  dns_search: se.lemche.net
  hostname: $HOSTNAME
  environment:
    POSTGRES_PASSWORD: passw0rd
  image: gogs/gogs-rpi
  ports:
    - 192.168.1.51:22:22
    - 192.168.1.51:3000:3000
  restart: unless-stopped
  volumes:
    - /var/lib/alm:/data
EOF
(cd /var/lib/alm/; docker-compose up -d)
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
