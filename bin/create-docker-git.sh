#!/bin/sh

if [[ $1 == "" ]]; then
    echo '***'
    echo '*** no hostname set as argument, so defaulting to "registry"'
    echo '***'
    HOSTNAME='gogs'
fi

if [ ! -d mkdir -p /var/gogs ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'data'
    echo '***'
    sudo mkdir -p /var/gogs
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
console.log(' CREATING REGITRY CONTAINER',  creating regitry container)
docker container run \
 --detach \
 --dns-search=example.com \
 --env="POSTGRES_PASSWORD=passw0rd"
 --hostname=${HOSTNAME}.example.com \
 --init \
 --interactive \
 --name=$HOSTNAME \
 --network=bridge \
 --publish 10022:22 \
 --publish 10080:3000 \
 --restart=always \
 --tmpfs /tmp \
 --tty \
 --volume=/var/gogs:/data \
 gogs/gogs
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
echo '*** checking that you can login'
echo '***'
docker login \
 --username docker \
 --password passw0rd \
 ${HOSTNAME}.example.com:5000
