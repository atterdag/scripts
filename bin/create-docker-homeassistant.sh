#!/bin/sh

if [ ! -d /var/lib/homeassistant/config ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'lovelace data'
    echo '***'
    sudo mkdir -p /var/lib/homeassistant/config
fi

echo '***'
echo -n '*** creating nginx configuration directory on host'
if [ ! -d /var/lib/homeassistant/nginx/conf.d ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'configuration'
    echo '***'
    sudo mkdir -p /var/lib/homeassistant/nginx/conf.d
fi
echo '***'

echo '***'
echo -n '*** creating nginx log directory on host'
if [ ! -d /var/lib/homeassistant/nginx/logs ]; then
    echo '***'
    echo '*** creating directory on host to store' ${HOSTNAME} 'logs'
    echo '***'
    sudo mkdir -p /var/lib/homeassistant/nginx/logs
fi
echo '***'

echo '***'
echo -n '*** stopping previous container named '
docker container stop homeassistant
echo '***'

echo '***'
echo -n '*** removing previous container named '
docker container rm homeassistant
echo '***'

cat <<EOF | sudo tee -a /var/lib/homeassistant/config/configuration.yaml

http:
  ssl_certificate: /config/fullchain.pem
  ssl_key: /config/privkey.pem
  server_port: 443
EOF

cat << EOF | sudo tee /var/lib/homeassistant/nginx/conf.d/homeassistant.se.lemche.net.conf
server {
  listen 80;
  server_name homeassistant.se.lemche.net;
  return 301 https://homeassistant.se.lemche.net$request_uri;
}
EOF
echo '***'

echo '***'
echo -n '*** ensure that /var/lib/homeassistant/ is readable for nginx user in container'
openssl x509 -in /etc/ssl/certs/homeassistant.se.lemche.net.crt \
| sudo tee /var/lib/homeassistant/config/fullchain.pem
openssl x509 -in /usr/local/share/ca-certificates/Lemche.NET_Intermediate_CA_1.crt \
| sudo tee -a /var/lib/homeassistant/config/fullchain.pem
sudo openssl rsa -in /etc/ssl/private/homeassistant.se.lemche.net.key \
| sudo tee /var/lib/homeassistant/config/privkey.pem
echo '***'

echo '***'
echo -n '*** ensure that /var/lib/homeassistant/ is readable for nginx user in container'
sudo chown root:root \
  /var/lib/homeassistant/config/privkey.pem \
  /var/lib/homeassistant/config/fullchain.pem
sudo chmod 600 \
  /var/lib/homeassistant/config/privkey.pem \
  /var/lib/homeassistant/config/fullchain.pem
echo '***'

cat << EOF | sudo tee /var/lib/homeassistant/docker-compose.yml
version: '3'
services:
  web:
    dns_search: se.lemche.net
    image: nginx:stable
    ports:
      - 192.168.1.55:80:80
    restart: unless-stopped
    volumes:
      - /var/lib/homeassistant/nginx/conf.d:/etc/nginx/conf.d
      - /var/lib/homeassistant/nginx/logs:/var/log/nginx
  app:
    environment:
      - TZ=Europe/Stockholm
    hostname: homeassistant
    image: homeassistant/raspberrypi4-homeassistant:stable
    ports:
      - 192.168.1.55:443:443
    volumes:
      - /var/lib/homeassistant/config:/config
    restart: always
EOF
(cd /var/lib/homeassistant/; docker-compose up -d)
