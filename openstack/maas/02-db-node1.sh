sudo sed -i -E 's|(^#max_wal_senders.*)|max_wal_senders = 10\n\1|' /etc/postgresql/12/main/postgresql.conf
sudo sed -i -E 's|(^#synchronous_commit.*)|synchronous_commit = on\n\1|' /etc/postgresql/12/main/postgresql.conf
sudo sed -i -E 's|(^#wal_keep_segments.*)|wal_keep_segments = 10\n\1|' /etc/postgresql/12/main/postgresql.conf
sudo sed -i -E 's|(^#wal_level.*)|wal_level = replica\n\1|' /etc/postgresql/12/main/postgresql.conf
sudo sed -i -E "s|(^#synchronous_standby_names.*)|synchronous_standby_names = '*'\n\1|" /etc/postgresql/12/main/postgresql.conf
cat <<EOF | sudo tee -a /etc/postgresql/12/main/pg_hba.conf
host    replication     ${MAAS_PG_REPLICATION_USERNAME}        ${MAAS_ONE_IP_ADDRESS}/32            md5
host    replication     ${MAAS_PG_REPLICATION_USERNAME}        ${MAAS_TWO_IP_ADDRESS}/32            md5
EOF
sudo -u postgres psql -c "CREATE USER ${MAAS_PG_REPLICATION_USERNAME} WITH REPLICATION ENCRYPTED PASSWORD 'MAAS_PG_REPLICATION_PASSWORD'"
sudo systemctl restart postgresql
