#!/bin/sh

if [ "$1" = "" ]; then
    echo '***'
    echo '*** no hostname set as argument, so defaulting to "joxit"'
    echo '***'
    HOSTNAME='joxit'
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
docker run \
 --detach \
 --env="URL=http://docker.example.com:5000" \
 --env="DELETE_IMAGES=true" \
 --hostname="$HOSTNAME" \
 --init \
 --interactive \
 --name="$HOSTNAME" \
 --publish=80:80 \
 --restart=always \
 --tmpfs /tmp \
 --tty \
 joxit/docker-registry-ui:static
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
