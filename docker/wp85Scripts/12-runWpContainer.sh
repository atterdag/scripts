#!/bin/sh

. `dirname $0`/properties.sh

docker container run \
 --detach \
 --init \
 --interactive \
 --publish=10041:10041 \
 --publish=10042:10042 \
 --publish=10039:10039 \
 --publish=10038:10038 \
 --publish=10033:10033 \
 --tmpfs=/tmp \
 --tty \
 registry.example.com:5000/wp85:${WP_CF}
