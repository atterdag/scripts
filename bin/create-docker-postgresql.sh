#!/bin/sh

if [ "$1" = "" ]; then
    echo '***'
    echo '*** no hostname set as argument, so defaulting to "joxit"'
    echo '***'
    HOSTNAME='postgres'
fi

if [ ! -d /var/lib/${HOSTNAME}/data ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'data'
    echo '***'
    sudo mkdir -p /var/lib/${HOSTNAME}/data
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
echo -n '*** generate password for postgres user '
PASSWORD=$(apg -m16 -x16 -n1 -MCNL)
echo '***'

echo '***'
echo -n '*** creating regitry container name' $HOSTNAME 'with ID '
cat << EOF | sudo tee /var/lib/${HOSTNAME}/docker-compose.yml
$HOSTNAME:
  container_name: $HOSTNAME
  dns_search: se.lemche.net
  hostname: $HOSTNAME
  environment:
    POSTGRES_USER: "postgres"
    POSTGRES_PASSWORD: "${PASSWORD}"
    POSTGRES_DB: "postgres"
    PGDATA: /var/lib/postgresql/data/pgdata
  image: postgres
  ports:
    - 192.168.0.53:5432:5432
  restart: always
  tmpfs:
    - /tmp
  environment:
    - /var/lib/${HOSTNAME}/data:/var/lib/postgresql/data:Z
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
