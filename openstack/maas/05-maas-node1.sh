sudo -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
sudo -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
cat <<EOF | sudo tee -a /etc/postgresql/12/main/pg_hba.conf
hostssl    $MAAS_DBNAME    $MAAS_DBUSER    ${MAAS_ONE_IP_ADDRESS}/32     md5
hostssl    $MAAS_DBNAME    $MAAS_DBUSER    ${MAAS_TWO_IP_ADDRESS}/32     md5
EOF
sudo systemctl reload postgresql
sudo ufw allow 5240
sudo ufw allow 5248
sudo ufw allow 5241:5247/tcp
sudo ufw allow 5241:5247/udp
sudo ufw allow 5250:5270/tcp
sudo ufw allow 5250:5270/udp

sudo snap install lxd
lxc profile copy default maas-profile
lxc profile device set maas-profile eth0 network lxdbr0
lxc launch --profile maas-profile ubuntu:20.04 bionic-maas
lxc exec bionic-maas -t -- wget --output-document=/usr/local/share/ca-certificates/${SSL_ROOT_CA_STRICT_NAME}.crt http://${SSL_ROOT_CA_FQDN}/${SSL_ROOT_CA_STRICT_NAME}.crt
lxc exec bionic-maas -t -- update-ca-certificates
lxc exec bionic-maas -t -- snap install maas
lxc exec bionic-maas -t -- maas init region+rack \
  --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@$MAAS_ONE_FQDN/$MAAS_DBNAME" \
  --maas-url "default=http://${MAAS_ONE_IP_ADDRESS}:5240/MAAS"
lxc exec bionic-maas -t -- maas createadmin \
  --username "${MAAS_ADMIN_USERNAME}" \
  --password "${MAAS_ADMIN_PASSWORD}" \
  --email "${MAAS_ADMIN_EMAIL}"

for port in 5240 5241 5242 5243 5244 5245 5246 5247 5248 5250 5251 5252 5253 5254 5255 5256 5257 5258 5259 5260 5261 5262 5263 5264 5265 5266 5267 5268 5269 5270; do
  lxc config device add bionic-maas maas${port}tcp proxy listen=tcp:0.0.0.0:${port} connect=tcp:127.0.0.1:${port}
  lxc config device add bionic-maas maas${port}udp proxy listen=udp:0.0.0.0:${port} connect=udp:127.0.0.1:${port}
done

sudo -u postgres psql -c "CREATE USER \"atterdag\" WITH ENCRYPTED PASSWORD '$PASSWORD'; ALTER USER \"atterdag\" WITH SUPERUSER;"
cat <<EOF | sudo tee -a /etc/postgresql/12/main/pg_hba.conf
hostssl   postgres    atterdag    192.168.1.128/32     md5
EOF
sudo systemctl reload postgresql
