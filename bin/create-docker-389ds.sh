#!/bin/sh

if [[ $1 == "" ]]; then
    echo '***'
    echo '*** no hostname set as argument, so defaulting to "registry"'
    echo '***'
    HOSTNAME='ldap'
fi

if [ ! -d /var/lib/${HOSTNAME}/auth ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'auth data'
    echo '***'
    sudo mkdir -p /var/lib/${HOSTNAME}/auth
fi

if [ ! -d /var/lib/${HOSTNAME}/certs ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'certificates'
    echo '***'
    sudo mkdir -p /var/lib/${HOSTNAME}/certs
fi

if [ ! -d /var/lib/${HOSTNAME}/data ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'regitry data'
    echo '***'
    sudo mkdir -p /var/lib/${HOSTNAME}/data
fi

echo '***'
echo -n '*** generate password for postgres user '
PASSWORD=$(apg -m16 -x16 -n1 -MCNL)
echo '***'

echo '***'
echo -n '*** stopping previous container named '
docker container stop $HOSTNAME
echo '***'

echo '***'
echo -n '*** removing previous container named '
docker container rm $HOSTNAME
echo '***'

echo '***'
echo '*** generating htpasswd for' ${HOSTNAME}
SHA_PASSWORD=$(docker container run \
 --name pwdhash \
 --entrypoint pwdhash \
 novalinc/389ds \
 $PASSWORD)
echo '***'

echo '***'
echo -n '*** removing container named '
docker container rm pwdhash
echo '***'

echo '***'
echo '*** copying SSL certificates to' ${HOSTNAME}
echo '***'
sudo cp /etc/ssl/certs/${HOSTNAME}.se.lemche.net.crt /var/lib/${HOSTNAME}/certs/server.crt
sudo cp /etc/ssl/private/${HOSTNAME}.se.lemche.net.key /var/lib/${HOSTNAME}/certs/server.key
sudo cp /usr/local/share/ca-certificates/Lemche.NET-CA.crt /var/lib/${HOSTNAME}/certs/ca.pem

cat << EOF | sudo tee /var/lib/${HOSTNAME}/docker-compose.yml
$HOSTNAME:
  container_name: $HOSTNAME
  dns_search: se.lemche.net
  hostname: $HOSTNAME
  environment:
    DIRSRV_FQDN: ${HOSTNAME}.se.lemche.net
    DIRSRV_SUFFIX: dc=se,dc=lemche,dc=net
    DIRSRV_PORT: LDAP Port (Default= 389)
    DIRSRV_ROOT_DN: cn=Directory Manager
    DIRSRV_ROOT_DN_PASSWORD: "$PASSWORD"
    DIRSRV_ADMIN_PORT: 9830
    DIRSRV_ID: dir
    DIRSRV_ADMIN_USERNAME: admin
    DIRSRV_ADMIN_PASSWORD: admin password (default: adminpassword)
    DIRSRV_ORG_ENTRIES: If yes, this directive creates the new Directory Server instance with a suggested directory structure and access control. If this directive is used and Bind Mount /usr/share/dirsrv/restore.ldif (internally uses InstallLdifFile) is also used, then this directive has no effect (default = no)
    DIRSRV_SAMPLE_ENTRIES: Sets whether to load an LDIF file with entries for the user directory during configuration (default = no).
  image: registry:2
  ports:
    - 192.168.1.50:5001:5001
  restart: unless-stopped
  volumes:
    - /var/lib/${HOSTNAME}/data:/var/lib/registry
    - /var/lib/${HOSTNAME}/certs:/certs:ro
    - /var/lib/${HOSTNAME}/auth:/auth:ro
    /etc/dirsrv - the location of instance and configuration data
    /var/lib/dirsrv - the location of directory server DB
    /var/log/dirsrv -  the logs of the directory server
    /usr/share/dirsrv/restore.ldif - location of restore file LDIF, use bind mount to link to this file from your host
EOF
(cd /var/lib/${HOSTNAME}/; docker-compose up -d)
(cd /var/lib/${HOSTNAME}/; docker-compose down)

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
 ${HOSTNAME}.se.lemche.net:5001

echo '***'
echo '*** create alias for performing a registry garbage collect on docker' ${HOSTNAME}
echo '***'
cat << EOF | sudo tee /etc/profile.d/docker-register.sh
alias registry-garbage-collect='docker container exec -it '$HOSTNAME' registry garbage-collect /etc/docker/registry/config.yml'
EOF
