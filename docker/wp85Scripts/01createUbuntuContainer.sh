#!/bin/bash

echo '*** reading properties.sh'
. `dirname $0`/properties.sh || exit 1

echo '*** pulling ubuntu trusty from docker repository'
docker image pull ubuntu:trusty

echo -n '*** stopping previous container named '
docker container stop $HOSTNAME

echo -n '*** removing previous container named '
docker container rm $HOSTNAME

echo -n '*** creating new container name' $HOSTNAME 'with ID '
docker container run \
 --detach \
 --dns=172.16.226.20 \
 --dns-search=$DOMAINNAME \
 --hostname=${HOSTNAME}.${DOMAINNAME} \
 --init \
 --interactive \
 --ip=$IP_ADDRESS \
 --name=$HOSTNAME \
 --network=$NETWORK_NAME \
 --publish=10041:10041 \
 --publish=10042:10042 \
 --publish=10039:10039 \
 --publish=10038:10038 \
 --publish=10033:10033 \
 --tmpfs /tmp \
 --tty \
 --volume=${SOURCE_NETWORK_PATH}:${SOURCE_PATH}:ro \
 --volume=$(dirname $0):/host/bin:ro \
 ubuntu:trusty \
 /bin/bash || exit 1

# echo '*** attaching to container named ' $HOSTNAME
# docker container attach $HOSTNAME || exit 1

echo '*** running /host/bin/installWpUbuntu.sh'
docker container exec\
 --tty\
 --interactive\
 $HOSTNAME\
 /host/bin/03installWpUbuntu.sh
