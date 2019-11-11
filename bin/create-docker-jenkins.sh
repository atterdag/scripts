#!/bin/sh

if [ "$1" = "" ]; then
    echo '***'
    echo '*** no hostname set as argument, so defaulting to "joxit"'
    echo '***'
    HOSTNAME='jenkins'
fi

if [ ! -d /var/lib/${HOSTNAME} ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'data'
    echo '***'
    sudo mkdir -p /var/lib/${HOSTNAME}
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
cat << EOF | sudo tee /var/lib/${HOSTNAME}/docker-compose.yml
$HOSTNAME:
  user: root
  container_name: $HOSTNAME
  dns_search: se.lemche.net
  hostname: $HOSTNAME
  image: jenkinsci/blueocean:latest
  ports:
    - 192.168.0.54:8080:8080
    - 192.168.0.54:50000:50000
  restart: unless-stopped
  volumes:
    - /var/lib/${HOSTNAME}:/var/jenkins_home
    - /var/run/docker.sock:/var/run/docker.sock
EOF
(cd /var/lib/${HOSTNAME}/; docker-compose up -d)
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

echo '***'
echo '*** obtain initial admin password'
echo '***'
docker container exec \
 $HOSTNAME \
 cat /var/jenkins_home/secrets/initialAdminPassword
