#!/bin/bash

echo '*** reading properties.sh'
. `dirname $0`/properties.sh || exit 1

echo '*** pulling centos from docker repository'
docker image pull centos

echo -n '*** stopping previous container named '
docker container stop $HOSTNAME

echo -n '*** removing previous container named '
docker container rm $HOSTNAME

echo -n '*** creating new container name' $HOSTNAME 'with ID '
docker container run \
 --name=$HOSTNAME \
 --hostname=${HOSTNAME}.${DOMAINNAME} \
 --ip=$IP_ADDRESS \
 --dns=172.16.226.20 \
 --dns-search=$DOMAINNAME \
 --network=$NETWORK_NAME \
 --volume=${SOURCE_NETWORK_PATH}:${SOURCE_PATH}:ro \
 --volume=$(dirname $0):/host/bin:ro \
 --tmpfs /tmp \
 --detach \
 --tty \
 --init \
 --interactive \
  centos\
 /bin/bash || exit 1

echo '*** attaching to container named ' $HOSTNAME
docker container attach $HOSTNAME || exit 1

#echo '*** running /host/bin/installWpCentos.sh'
#docker container exec\
# --tty\
# --interactive\
# $HOSTNAME\
# /host/bin/installWpCentos.sh