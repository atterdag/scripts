#!/bin/bash

##############################################################################
# Install Database on Controller host
##############################################################################
sudo apt-get --yes --quiet install \
  mariadb-server \
  python-pymysql

cat << EOF | sudo tee /etc/mysql/mariadb.conf.d/99-openstack.cnf
[mysqld]
bind-address = ${CONTROLLER_IP_ADDRESS}
default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
sudo systemctl restart mysql

sudo mysqladmin password "${ROOT_DBPASS}"
cat << EOF | sudo tee /var/lib/openstack/mysql_secure_installation.sql
# SQL script performing actions in mysql_secure_installation
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
# Default mariadb doesn't create test database
#DROP DATABASE test;
#DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF
sudo chmod 0600 /var/lib/openstack/mysql_secure_installation.sql
sudo cat /var/lib/openstack/mysql_secure_installation.sql | sudo mysql --host=localhost --user=root
echo "SELECT Host,User,Password FROM mysql.user WHERE User='root';" | sudo mysql --host=localhost --port=3306 --user=root --password="${ROOT_DBPASS}"
