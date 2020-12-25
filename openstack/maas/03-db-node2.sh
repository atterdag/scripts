sudo systemctl stop postgresql
for file in $(sudo ls -1 /var/lib/postgresql/12/main/); do
  sudo rm -fr /var/lib/postgresql/12/main/$file
done

export PGPASSWORD="${MAAS_PG_REPLICATION_PASSWORD}"
sudo --preserve-env -u postgres pg_basebackup --write-recovery-conf --host=$MAAS_ONE_FQDN --username=$MAAS_PG_REPLICATION_USERNAME --pgdata=/var/lib/postgresql/12/main --progress --verbose

sudo sed -i -E 's|(^#hot_standby\s.*)|hot_standby = on\n\1|' /etc/postgresql/12/main/postgresql.conf
cat <<EOF | sudo tee -a /etc/postgresql/12/main/pg_hba.conf
host    replication     ${MAAS_PG_REPLICATION_USERNAME}        ${MAAS_ONE_IP_ADDRESS}/32            md5
host    replication     ${MAAS_PG_REPLICATION_USERNAME}        ${MAAS_TWO_IP_ADDRESS}/32            md5
EOF

sudo systemctl start postgresql
