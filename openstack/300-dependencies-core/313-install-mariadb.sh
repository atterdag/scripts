#!/bin/bash

##############################################################################
# Install Database on Controller host
##############################################################################
sudo apt-get --yes --quiet install \
  software-properties-common
sudo apt-key adv --fetch-keys \
  'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository \
  'deb [arch=amd64,arm64,ppc64el] http://mirror.jaleco.com/mariadb/repo/10.3/ubuntu bionic main'

sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install \
  mariadb-server \
  python3-pymysql

sudo mysqladmin --host=localhost --port=3306 password "${ROOT_DBPASS}"

cat <<EOF | sudo tee ${OS_CONFIGURATION_DIRECTORY}/mysql_secure_installation.sql
# SQL script performing actions in mysql_secure_installation
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
# Default mariadb doesn't create test database
#DROP DATABASE test;
#DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF
sudo chmod 0600 ${OS_CONFIGURATION_DIRECTORY}/mysql_secure_installation.sql
sudo cat ${OS_CONFIGURATION_DIRECTORY}/mysql_secure_installation.sql \
  | sudo mysql --user=root --password="${ROOT_DBPASS}"
echo "SELECT Host,User,Password FROM mysql.user WHERE User='root';" \
  | sudo mysql --host=localhost --port=3306 --user=root --password="${ROOT_DBPASS}"

cat <<EOF | sudo tee /etc/mysql/mariadb.conf.d/99-openstack.cnf
[mysqld]
bind-address = ${OS_CONTROLLER_IP_ADDRESS}
default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
sudo systemctl restart mysql
