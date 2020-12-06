sudo apt install -y postgresql
sudo sed -i -E "s|(^#listen_addresses.*)|listen_addresses = '*'\n\1|" /etc/postgresql/12/main/postgresql.conf
sudo sed -i -E "s|(^#cluster_name.*)|cluster_name = 'maas'\n\1|" /etc/postgresql/12/main/postgresql.conf
sudo sed -i -E "s|^.*ssl_ca_file\s=.*|ssl_ca_file = '/etc/ssl/certs/ca-certificates.crt'|" /etc/postgresql/12/main/postgresql.conf
sudo sed -i -E "s|^.*ssl_cert_file.*|ssl_cert_file = '/etc/ssl/certs/$(hostname -f).crt'|" /etc/postgresql/12/main/postgresql.conf
sudo sed -i -E "s|^.*ssl_key_file.*|ssl_key_file = '/etc/ssl/private/$(hostname -f).key'|" /etc/postgresql/12/main/postgresql.conf
sudo ufw allow postgresql
sudo systemctl restart postgresql
