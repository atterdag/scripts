#!/bin/sh

if [ "$1" = "" ]; then
    echo '***'
    echo '*** no hostname set as argument, so defaulting to "alm"'
    echo '***'
    HOSTNAME='alm'
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
echo -n '*** creating nginx configuration directory on host'
if [ ! -d /var/lib/alm/conf.d ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'configuration'
    echo '***'
    sudo mkdir -p /var/lib/alm/conf.d
fi
echo '***'

echo '***'
echo -n '*** creating nginx ssl directory on host'
if [ ! -d /var/lib/alm/ssl ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'ssl certs and keys'
    echo '***'
    sudo mkdir -p /var/lib/alm/ssl
fi
echo '***'

echo '***'
echo -n '*** creating nginx log directory on host'
if [ ! -d /var/lib/alm/logs ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'logs'
    echo '***'
    sudo mkdir -p /var/lib/alm/logs
fi
echo '***'

cat << EOF | sudo tee /var/lib/alm/conf.d/ssl.conf
# SSL
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;

# modern configuration
ssl_protocols TLSv1.2;
ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256;
ssl_prefer_server_ciphers on;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4 208.67.222.222 208.67.220.220 valid=60s;
resolver_timeout 2s;
EOF
echo '***'

cat << EOF | sudo tee /var/lib/alm/conf.d/gogs.se.lemche.net.conf
server {
  listen 80;
  server_name gogs.se.lemche.net;
  return 301 https://gogs.se.lemche.net$request_uri;
}

server {
  listen 443 ssl http2;
  server_name gogs.se.lemche.net;
  ssl_certificate /etc/nginx/ssl/${HOSTNAME}.se.lemche.net.crt;
  ssl_certificate_key /etc/nginx/ssl/${HOSTNAME}.se.lemche.net.key;
  ssl_trusted_certificate /etc/nginx/ssl/ca-certificates.crt;
  access_log /var/log/nginx/gogs.se.lemche.net.access.log;
  error_log /var/log/nginx/gogs.se.lemche.net.error.log warn;
  location / {
    proxy_pass http://192.168.1.51:3000;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOF
echo '***'

cat << EOF | sudo tee /var/lib/alm/conf.d/awx.se.lemche.net.conf
server {
  listen 80;
  server_name awx.se.lemche.net;
  return 301 https://awx.se.lemche.net$request_uri;
}

server {
  listen 443 ssl http2;
  server_name awx.se.lemche.net;
  ssl_certificate /etc/nginx/ssl/${HOSTNAME}.se.lemche.net.crt;
  ssl_certificate_key /etc/nginx/ssl/${HOSTNAME}.se.lemche.net.key;
  ssl_trusted_certificate /etc/nginx/ssl/ca-certificates.crt;
  access_log /var/log/nginx/awx.se.lemche.net.access.log;
  error_log /var/log/nginx/awx.se.lemche.net.error.log warn;
  location / {
    proxy_pass http://192.168.1.53:8080;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOF
echo '***'

cat << EOF | sudo tee /var/lib/alm/conf.d/jenkins.se.lemche.net.conf
server {
  listen 80;
  server_name jenkins.se.lemche.net;
  return 301 https://jenkins.se.lemche.net$request_uri;
}

server {
  listen 443 ssl http2;
  server_name jenkins.se.lemche.net;
  ssl_certificate /etc/nginx/ssl/${HOSTNAME}.se.lemche.net.crt;
  ssl_certificate_key /etc/nginx/ssl/${HOSTNAME}.se.lemche.net.key;
  ssl_trusted_certificate /etc/nginx/ssl/ca-certificates.crt;
  access_log /var/log/nginx/jenkins.se.lemche.net.access.log;
  error_log /var/log/nginx/jenkins.se.lemche.net.error.log warn;
  location / {
    proxy_pass http://192.168.1.54:8080;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOF
echo '***'

echo '***'
echo -n '*** ensure that /var/lib/'$HOSTNAME'/ is readable for nginx user in container'
sudo cp /etc/ssl/certs/${HOSTNAME}.se.lemche.net.crt /var/lib/alm/ssl
sudo cp /etc/ssl/private/${HOSTNAME}.se.lemche.net.key /var/lib/alm/ssl
sudo cp /etc/ssl/certs/ca-certificates.crt /var/lib/alm/ssl
echo '***'

echo '***'
echo -n '*** ensure that /var/lib/'$HOSTNAME'/ is readable for nginx user in container'
sudo chmod -R 0755 /var/lib/alm
sudo chown -R 101:101 /var/lib/alm
echo '***'

echo '***'
echo -n '*** creating regitry container name' $HOSTNAME 'with ID '
cat << EOF | sudo tee /var/lib/alm/docker-compose.yml
$HOSTNAME:
  container_name: $HOSTNAME
  dns_search: se.lemche.net
  hostname: $HOSTNAME
  image: nginx:stable
  ports:
    - 192.168.1.42:80:80
    - 192.168.1.42:443:443
    - 192.168.1.51:80:80
    - 192.168.1.51:443:443
    # - 192.168.1.53:80:80
    # - 192.168.1.53:443:443
    # - 192.168.1.54:80:80
    # - 192.168.1.54:443:443
  restart: unless-stopped
  volumes:
    - /var/lib/alm/conf.d:/etc/nginx/conf.d
    - /var/lib/alm/ssl:/etc/nginx/ssl
    - /var/lib/alm/logs:/var/log/nginx
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
