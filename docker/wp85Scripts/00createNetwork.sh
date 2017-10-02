#!/bin/bash

echo '*** reading properties.sh'
. `dirname $0`/properties.sh || exit 1

echo '*** creating user defined network'
docker network create\
 --driver=bridge\
 --subnet="${NETWORK}/${NETWORK_MASK}"\
 $NETWORK_NAME
